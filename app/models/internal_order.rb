class InternalOrder < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  enum applicant_status: { borrador: 0, solicitado: 1, auditoria: 2, en_camino: 3, recibido: 4, anulado: 5 }, _prefix: :applicant
  enum provider_status: { nuevo: 0, auditoria: 1, en_camino: 2, entregado: 3, anulado: 4 }, _prefix: :provider

  # Relaciones
  belongs_to :applicant_sector, class_name: 'Sector'
  belongs_to :provider_sector, class_name: 'Sector'
  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots, dependent: :destroy
  has_many :supply_lots, -> { with_deleted }, :through => :sector_supply_lots
  has_many :supplies, -> { with_deleted }, :through => :quantity_ord_supply_lots

  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :sent_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true

  # Validaciones
  validates_presence_of :provider_sector
  validates_presence_of :applicant_sector
  validates_presence_of :requested_date
  validates_presence_of :quantity_ord_supply_lots
  validates_associated :quantity_ord_supply_lots
  validates_associated :sector_supply_lots

  # Atributos anidados
  accepts_nested_attributes_for :quantity_ord_supply_lots,
          :reject_if => :all_blank,
          :allow_destroy => true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_applicant,
      :search_supply_code,
      :search_supply_name,
      :with_status,
      :requested_date_at,
      :received_date_at,
      :sorted_by
    ]
  )

  pg_search_scope :search_supply_code,
  :associated_against => { :supply_lots => :code },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply_name,
  :associated_against => { :supply_lots => :supply_name },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_applicant,
  :associated_against => { :applicant_sector => :name },
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

  scope :requested_date_at, lambda { |reference_time|
    where('internal_orders.requested_date = ?', reference_time)
  }

  scope :received_date_at, lambda { |reference_time|
    where('internal_orders.received_date = ?', reference_time)
  }

  scope :with_sector_id, lambda { |an_id|
    where(sector_id: [*an_id])
  }

  scope :with_status, lambda { |a_status|
    where('internal_orders.provider_status = ?', a_status)
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

  # Cambia estado a "en camino" y descuenta la cantidad a los lotes de insumos
  def send_order
    if provider_anulado?
      raise ArgumentError, "El pedido está anulado"
    elsif provider_en_camino?
      raise ArgumentError, "El pedido ya se encuentra en camino"
    else
      if self.quantity_ord_supply_lots.exists?
        if self.quantity_ord_supply_lots.where.not(sector_supply_lot: nil).exists?
          self.quantity_ord_supply_lots.each do |qosl|
            qosl.decrement
          end
        else
          raise ArgumentError, 'No hay insumos a entregar en el pedido'
        end # End check if sector supply exists
      else
        raise ArgumentError, 'No hay insumos solicitados en el pedido'
      end # End check if quantity_ord_supply_lots exists
      self.sent_date = DateTime.now
      self.applicant_en_camino!
      self.provider_en_camino!
    end # End anulado?
  end

  # Método para retornar perdido a estado anterior
  def return_provider_status
    if provider_auditoria?
      raise ArgumentError, "No hay más estados a retornar"
    elsif provider_en_camino?
      self.quantity_ord_supply_lots.each do |qosl|
        qosl.increment
      end
      self.sent_by = nil
      self.sent_date = nil
      self.provider_auditoria!
    elsif provider_entregado?
      raise ArgumentError, "Ya se ha entregado el pedido"
    end
  end

  # Cambia estado del pedido a "Aceptado" y se verifica que hayan lotes
  def receive_order(a_sector)
    if provider_anulado? || applicant_anulado?
      raise ArgumentError, "El pedido está anulado"
    elsif provider_auditoria?
      raise ArgumentError, "El pedido se encuentra en auditoria"
    elsif provider_entregado?
      raise ArgumentError, "El pedido ya ha sido entregado"
    elsif provider_en_camino?
      if self.quantity_ord_supply_lots.where.not(sector_supply_lot: nil).exists?
        self.quantity_ord_supply_lots.each do |qosl|
          qosl.increment_lot_to(a_sector)
        end
        self.date_received = DateTime.now
        self.provider_entregado!
        self.applicant_recibido!
      else
        raise ArgumentError, 'No hay insumos para recibir en el pedido'
      end # End chack if sector supply exists
    end #End anulado?
  end

  # Label del estado para vista.
  def applicant_status_label
    if self.applicant_borrador?; return 'default'
    elsif self.applicant_solicitado?; return 'info'
    elsif self.applicant_auditoria?; return 'warning'
    elsif self.applicant_en_camino?; return 'primary'
    elsif self.applicant_recibido?; return 'success'
    elsif self.applicant_anulado?; return 'danger'
    end
  end

  # Label del estado para vista.
  def provider_status_label
    if self.provider_nuevo?; return 'info'
    elsif self.provider_auditoria?; return 'warning'
    elsif self.provider_en_camino?; return 'primary'
    elsif self.provider_entregado?; return 'success'
    elsif self.provider_anulado?; return 'danger'
    end
  end

  # Porcentaje de la barra de estado
  def percent_status
    if self.provider_nuevo?; return 5
    elsif self.provider_auditoria?; return 34
    elsif self.provider_en_camino?; return 71
    elsif self.provider_entregado?; return 100
    elsif self.provider_anulado?; return 100
    end
  end

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Nuevos', 0, 'info'],
      ['Auditoria', 1, 'warning'],
      ['En Camino', 2, 'primary'],
      ['Entregado', 3, 'success'],
      ['Anulado', 4, 'danger'],
    ]
   end
end
