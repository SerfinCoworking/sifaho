class InternalOrderBak < ApplicationRecord
  include PgSearch::Model

  enum order_type: { provision: 0, solicitud: 1 }

  enum status: { solicitud_auditoria: 0, solicitud_enviada: 1, proveedor_auditoria: 2, provision_en_camino: 3, 
    provision_entregada: 4, anulado: 5 }
  
  # Relaciones
  belongs_to :applicant_sector, class_name: 'Sector'
  belongs_to :provider_sector, class_name: 'Sector'
  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots, dependent: :destroy
  has_many :supply_lots, -> { with_deleted }, :through => :sector_supply_lots
  has_many :supplies, -> { with_deleted }, :through => :quantity_ord_supply_lots
  has_many :movements, class_name: "InternalOrderMovement", foreign_key: "internal_order_id"
  has_many :comments, class_name: "InternalOrderComment", foreign_key: "order_id"

  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :sent_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true
  belongs_to :sent_request_by, class_name: 'User', optional: true
  belongs_to :rejected_by, class_name: "User", optional: true

  # Validaciones
  validates_presence_of :provider_sector, :applicant_sector, :requested_date, :remit_code

  # Atributos anidados
  accepts_nested_attributes_for :quantity_ord_supply_lots,
    :reject_if => :all_blank,
    :allow_destroy => true

  # Callbacks
  # before_validation :record_remit_code, on: :create

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_code,
      :search_applicant,
      :search_provider,
      :with_order_type,
      :with_status,
      :requested_date_since,
      :requested_date_to,
      :date_received_since,
      :date_received_to,
      :sorted_by
    ]
  )

  pg_search_scope :search_code,
    :against => :remit_code,
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_applicant,
    :associated_against => { :applicant_sector => :name },
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_provider,
    :associated_against => { :provider_sector => :name },
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.


  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
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

  public

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

  # Nullify the order
  def nullify_by(a_user)
    self.rejected_by = a_user
    self.anulado!
    self.create_notification(a_user, "anuló")
  end

  # Cambia estado a "en camino" y descuenta la cantidad a los lotes de insumos
  def send_order_by(a_user)
    if self.provider_sector == a_user.sector
      if self.quantity_ord_supply_lots.exists?
        if self.validate_quantity_lots
          self.quantity_ord_supply_lots.each do |qosl|
            qosl.decrement
          end
        end
      else
        raise ArgumentError, 'No hay insumos solicitados en el pedido'
      end # End check if quantity_ord_supply_lots exists
      self.sent_date = DateTime.now
      self.sent_by_id = a_user.id
      self.provision_en_camino!
      self.create_notification(a_user, "envió")
    else
      raise ArgumentError, 'Usted no pertenece al sector proveedor.'
    end
  end

  def send_request_by(a_user)
    if self.solicitud_auditoria?
      self.sent_request_by = a_user
      self.solicitud_enviada!
      self.create_notification(a_user, "envió")
    else
      raise ArgumentError, 'La solicitud no se encuentra en auditoría.'
    end
  end

  # Método para retornar perdido a estado anterior
  def return_provider_status_by(a_user)
    if provision_en_camino?
      self.quantity_ord_supply_lots.each do |qosl|
        qosl.increment
      end
      self.sent_by = nil
      self.sent_date = nil
      self.create_notification(a_user, "retornó a un estado anterior")
      self.proveedor_auditoria!
    else
      raise ArgumentError, "No es posible retornar a un estado anterior"
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

  # Cambia estado del pedido a "Aceptado" y se verifica que hayan lotes
  def receive_order_by(a_user)
    if self.provision_en_camino?
      if self.quantity_ord_supply_lots.where.not(sector_supply_lot: nil).exists?
        self.quantity_ord_supply_lots.each do |qosl|
          qosl.increment_lot_to(a_user.sector)
        end
        self.date_received = DateTime.now
        self.received_by = a_user
        self.create_notification(a_user, "recibió")
        self.provision_entregada!
      else
        raise ArgumentError, 'No hay insumos para recibir en la provisión.'
      end # End check if sector supply exists
    else
      raise ArgumentError, 'La provisión aún no está en camino.'
    end
  end

  # Método para validar las cantidades a entregar de los lotes en stock
  def validate_quantity_lots
    @qosl_with_ssl = self.quantity_ord_supply_lots.where.not(sector_supply_lot_id: nil) # Donde existe el lote
    @qosl_without_ssl = self.quantity_ord_supply_lots.where(sector_supply_lot_id: nil) # Donde existe el lote
    if @qosl_with_ssl.present?
      @sect_lots = @qosl_with_ssl.select('sector_supply_lot_id, delivered_quantity').group_by(&:sector_supply_lot_id) # Agrupado por lote
      # Se itera el hash por cada lote sumando y verificando las cantidades.
      @sect_lots.each do |key, values|
        @sum_quantities = values.inject(0) { |sum, lot| sum += lot[:delivered_quantity]}
        @sector_lot = SectorSupplyLot.find(key)
        if @sector_lot.quantity < @sum_quantities
          raise ArgumentError, 'Stock insuficiente del lote '+@sector_lot.lot_code+' insumo: '+@sector_lot.supply_name
        end
      end
    elsif @qosl_without_ssl.present?
      @qosl_without_ssl.each do |qosl|
        if qosl.delivered_quantity > 0
          raise ArgumentError, 'No hay lote asignado para el insumo cód '+ qosl.supply_id.to_s 
        end
      end
    else
      raise ArgumentError, 'No hay insumos en el pedido.'
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

  private

  def record_remit_code
    if self.provision?
      self.remit_code = self.provider_sector.name[0..3].upcase+'prov'+InternalOrder.maximum(:id).to_i.next.to_s
    elsif self.solicitud?
      self.remit_code = self.applicant_sector.name[0..3].upcase+'sol'+InternalOrder.maximum(:id).to_i.next.to_s
    end
  end
end
