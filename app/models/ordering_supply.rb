class OrderingSupply < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  enum status: { preparando: 0, pendiente: 1, recibido: 2, anulado: 3 }

  # Relaciones
  belongs_to :responsable, class_name: 'User'
  has_one :profile, :through => :responsable
  belongs_to :sector
  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots

  # Validaciones
  validates_presence_of :responsable
  validates_presence_of :sector
  validates_presence_of :quantity_ord_supply_requests
  validates_presence_of :supply_lots
  validates_associated :quantity_ord_supply_requests
  validates_associated :supply_lots

  accepts_nested_attributes_for :supply_lots
  accepts_nested_attributes_for :quantity_ord_supply_lots,
          :reject_if => :all_blank,
          :allow_destroy => true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_responsable,
      :search_lot_code,
      :search_supply,
      :sorted_by,
      :date_received_at,
    ]
  )

  pg_search_scope :search_lot_code,
  :associated_against => { :supply_lots => :lot_code },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply,
  :associated_against => { :supply_lots => :supply_name, :supply_lots => :code },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_responsable,
  :associated_against => { :profile => :first_name, :profile => :last_name, :responsable => :username },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("ordering_supplies.created_at #{ direction }")
    when /^responsable_/
      # Ordenamiento por nombre de responsable
      order("LOWER(responsable.username) #{ direction }").joins("INNER JOIN users as responsable ON responsable.id = ordering_supplies.responsable_id")
    when /^sector_/
      # Ordenamiento por nombre de sector
      order("sectors.sector_name #{ direction }").joins(:sector)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("ordering_supplies.status #{ direction }")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de insumo solicitado
      order("supply_lots.supply_name #{ direction }").joins(:supply_lots)
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("ordering_supplies.date_received #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_at, lambda { |reference_time|
    where('ordering_supplies.date_received >= ?', reference_time)
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
    ]
  end

  def deliver
    if entregado?
      raise ArgumentError, "Ya se ha entregado este pedido"
    else
      if self.quantity_supply_lots.present?
        self.quantity_supply_lots.each do |qsls|
          qsls.decrement
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
    if self.armando?
      return 'default'
    elsif self.pendiente?
      return 'info'
    elsif self.recibido?
      return 'success'
    elsif self.anulado?
      return 'danger'
    end
  end

  private

  def assign_sector
    self.sector = self.responsable.sector
  end

end
