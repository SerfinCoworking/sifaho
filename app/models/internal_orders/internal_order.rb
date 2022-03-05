class InternalOrder < ApplicationRecord
  include PgSearch::Model
  include Order

  enum order_type: { provision: 0, solicitud: 1 }
  enum status: { solicitud_auditoria: 0, solicitud_enviada: 1, proveedor_auditoria: 2, provision_en_camino: 3,
                 provision_entregada: 4, anulado: 5 }

  # Relationships
  has_many :order_products, dependent: :destroy, class_name: 'InternalOrderProduct', foreign_key: 'order_id',
                            inverse_of: 'order'
  has_many :int_ord_prod_lot_stocks, through: :order_products, inverse_of: :order, source: :order_prod_lot_stocks
  has_many :movements, class_name: 'InternalOrderMovement'
  has_many :comments, class_name: 'InternalOrderComment', foreign_key: 'order_id'

  validates_associated :order_products

  # Nested attributes
  accepts_nested_attributes_for :order_products,
                                reject_if: proc { |attributes| attributes['product_id'].blank? },
                                allow_destroy: true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: %i[search_code search_applicant search_provider with_order_type with_status requested_date_since
                          requested_date_to date_received_since date_received_to sorted_by]
  )

  pg_search_scope :search_code,
                  against: :remit_code,
                  using: { tsearch: { prefix: true }, trigram: {} }, # Buscar coincidencia en cualquier parte del string
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_applicant,
                  associated_against: { applicant_sector: :name },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_provider,
                  associated_against: { provider_sector: :name },
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("internal_orders.created_at #{ direction }")
    when /^solicitante_/
      # Ordenamiento por nombre de responsable
      order("LOWER(applicant_sector.name) #{ direction }").joins("INNER JOIN sectors as applicant_sector ON applicant_sector.id = internal_orders.applicant_sector_id")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de sector
      order("supplies.name #{ direction }").joins(:supplies)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("internal_orders.status #{ direction }")
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("internal_orders.date_received #{ direction }")
    when /^entregado_/
      # Ordenamiento por la fecha de dispensación
      order("internal_orders.date_delivered #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_since, lambda { |a_date|
    where('internal_orders.date_received >= ?', a_date)
  }

  scope :date_received_to, lambda { |a_date|
    where('internal_orders.date_received <= ?', a_date)
  }

  scope :requested_date_since, lambda { |a_date|
    where('internal_orders.requested_date >= ?', a_date)
  }

  scope :requested_date_to, lambda { |a_date|
    where('internal_orders.requested_date <= ?', a_date)
  }

  scope :with_order_type, lambda { |a_type|
    where('internal_orders.order_type = ?', a_type)
  }

  scope :with_status, lambda { |a_status|
    where('internal_orders.status = ?', a_status)
  }

  scope :without_status, lambda { |a_status|
    where.not('internal_orders.status = ?', a_status )
  }

  def self.applicant(a_sector)
    where(applicant_sector: a_sector)
  end

  def self.provider(a_sector)
    where(provider_sector: a_sector)
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Sector (a-z)', 'sector_asc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recibido (asc)', 'recibido_desc'],
      ['Fecha entregado (asc)', 'entregado_asc'],
      ['Cantidad (asc)', 'cantidad_asc']
    ]
  end

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Solicitud auditoria', 0, 'warning'],
      ['Solicitud enviada', 1, 'info'],
      ['Proveedor auditoria', 2, 'warning'],
      ['Provision en camino', 3, 'primary'],
      ['Provision entregada', 4, 'success'],
      ['Anulado', 5, 'danger'],
    ]
  end

  def is_provider?(a_user)
    return self.provider_sector == a_user.sector
  end

  def is_applicant?(a_user)
    return self.applicant_sector == a_user.sector
  end

  def sum_to?(a_sector)
    return self.applicant_sector == a_sector
  end

  def delivered_with_sector?(a_sector)
    if self.provision_en_camino? || self.provision_entregada?
      return self.provider_sector == a_sector || self.applicant_sector == a_sector
    end
  end

  # Método para retornar perdido a estado anterior
  def return_applicant_status_by(a_user)
    if solicitud_enviada?
      self.create_notification(a_user, "retornó a un estado anterior")
      self.solicitud_auditoria!
    else
      raise ArgumentError, "No es posible retornar a un estado anterior"
    end
  end

  def create_notification(of_user, action_type)
    InternalOrderMovement.create(user: of_user, internal_order: self, action: action_type, sector: of_user.sector)
    (self.applicant_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: self.order_type, action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
    (self.provider_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: self.order_type, action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  def get_statuses
    @statuses =self.class.statuses

    if self.solicitud?
      # si es anulado, devolvemos solo los 2 primeros estados y "anulado"
      if self.anulado?
        values = @statuses.except("proveedor_auditoria", "provision_en_camino", "provision_entregada")
      else
        values = @statuses.except("anulado")
      end
    else
      values = @statuses.except("solicitud_auditoria", "solicitud_enviada", "anulado")
    end

    return values
  end

  # status: ["key_name", 0], trae dos valores, el nombre del estado y su valor entero del enum definido
  def set_status_class(status)
    status_class = self.anulado? ? "anulado" : "active";
    # obetenemos el valor del status del objeto. 
    self_status_int = InternalOrder.statuses[self.status]
    return status[1] <= self_status_int ? status_class : ""
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    self.provider_sector.name
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    self.applicant_sector.name
  end

  private

  def record_remit_code
    self.remit_code = "SE#{DateTime.now.to_s(:number)}"
  end

  def presence_of_products_into_the_order
    if self.order_products.size == 0
      errors.add(:presence_of_products_into_the_order, 'Debe agregar almenos 1 producto')
    end
  end
end
