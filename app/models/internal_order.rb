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
      :search_responsable,
      :search_supply_code,
      :search_supply_name,
      :sorted_by,
      :requested_date_at,
      :received_date_at,
    ]
  )

  pg_search_scope :search_supply_code,
  :associated_against => { :supplies => :id, :supply_lots => :code },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply_name,
  :associated_against => { :supplies => :name, :supply_lots => :supply_name },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_responsable,
  :associated_against => { profile: [:last_name, :first_name], :responsable => :username },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.


  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("internal_orders.created_at #{ direction }")
    when /^responsable_/
      # Ordenamiento por nombre de responsable
      order("LOWER(responsable.username) #{ direction }").joins("INNER JOIN users as responsable ON responsable.id = internal_orders.responsable_id")
    when /^sector_/
      # Ordenamiento por nombre de sector
      order("sectors.name #{ direction }").joins(:sector)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("internal_orders.status #{ direction }")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de insumo solicitado
      order("supplies.name #{ direction }").joins(:supplies)
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

  def deliver
    if enviado?
      raise ArgumentError, "Ya se ha enviado este pedido"
    else
      if self.quantity_supply_lots.present?
        self.quantity_supply_lots.each do |qsls|
          qsls.decrement
          qsls.increment_lot_to(self.applicant.sector)
        end
      else
        raise ArgumentError, 'No hay lotes en el pedido'
      end
      self.date_delivered = DateTime.now
      self.enviado!
    end #End entregado?
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
end
