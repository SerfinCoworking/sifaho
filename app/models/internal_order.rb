class InternalOrder < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  enum status: { pendiente: 0, entregado: 1, anulado: 2 }

  # Callbacks
  before_validation :assign_sector

  # Relaciones
  belongs_to :applicant, class_name: 'User'
  belongs_to :provider, class_name: 'User'
  has_one :profile, :through => :applicant
  has_one :profile, :through => :provider
  belongs_to :sector
  has_many :quantity_supply_requests, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :supplies, -> { with_deleted }, :through => :quantity_supply_requests, dependent: :destroy
  has_many :quantity_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_supply_lots, dependent: :destroy

  # Validaciones
  validates_presence_of :applicant
  validates_presence_of :provider
  validates_presence_of :sector
  validates_presence_of :date_received
  validates_presence_of :quantity_supply_requests
  validates_associated :quantity_supply_requests
  validates_associated :supplies
  validates_associated :quantity_supply_lots
  validates_associated :sector_supply_lots

  # Atributos anidados
  accepts_nested_attributes_for :quantity_supply_requests,
          :reject_if => :all_blank,
          :allow_destroy => true
  accepts_nested_attributes_for :supplies
  accepts_nested_attributes_for :quantity_supply_lots,
          :reject_if => :all_blank,
          :allow_destroy => true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_responsable,
      :search_supply_code,
      :search_supply_name,
      :sorted_by,
      :date_received_at,
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
      order("sectors.sector_name #{ direction }").joins(:sector)
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

  scope :date_received_at, lambda { |reference_time|
    where('internal_orders.date_received >= ?', reference_time)
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
    if entregado?
      raise ArgumentError, "Ya se ha entregado este pedido"
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
      self.entregado!
    end #End entregado?
  end

  # Label del estado para vista.
  def status_label
    if self.entregado?
      return 'success'
    elsif self.pendiente?
      return 'default'
    elsif self.anulado?
      return 'danger'
    end
  end

  private

  def assign_sector
    self.sector = self.provider.sector
  end
end
