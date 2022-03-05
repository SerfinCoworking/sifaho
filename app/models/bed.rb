class Bed < ApplicationRecord
  include PgSearch::Model
  enum status: { disponible: 0, ocupada: 1, inactiva: 2 } 

  # Relationships
  belongs_to :bedroom
  belongs_to :service, class_name: 'Sector'
  has_one :establishment, through: :bedroom
  has_many :bed_orders
  has_one :patient
  has_many :inpatient_movements
  has_many :inpatient_prescriptions

  # Validations
  validates :name, :bedroom, presence: true
  validates :name, presence: true, uniqueness: { scope: :bedroom, case_sensitive: false, message: "existente en la habicación" }

  # Delegations
  delegate :name, to: :bedroom, prefix: :bedroom
  delegate :name, to: :service, prefix: :service
  delegate :fullname, :dni, :age_string, :id, to: :patient, prefix: :patient


  filterrific(
    default_filter_params: { sorted_by: 'estado_desc' },
    available_filters: [
      :search_name,
      :search_sector,
      :sorted_by,
      :for_statuses,
      :by_bedroom
    ]
  )

  # Scopes
  scope :establishment, ->(establishment_id) { joins(:establishment).where('establishments.id = ?', establishment_id) }

  pg_search_scope :search_name,
                  against: :name,
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^cama_/
      # Ordenamiento por nombre de sector
      reorder("beds.name #{ direction }")
    when /^sector_/
      # Ordenamiento por nombre de estado
      reorder("sectors.name #{ direction }").joins(:sector)
    when /^estado_/
      # Ordenamiento por nombre de estado
      reorder("beds.status #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_sorted_by
    [
      ['Cama (a-z)', 'cama_desc'],
      ['Cama (z-a)', 'cama_asc'],
      ['Sector (a-z)', 'sector_desc'],
      ['Sector (z-a)', 'sector_asc'],
      ['Estado (a-z)', 'estado_desc'],
      ['Estado (z-a)', 'estado_asc'],
    ]
  end

  def self.options_for_status
    [
      ['Disponible', 'disponible', 'success'],
      ['Ocupada', 'ocupada', 'warning'],
      ['Inactiva', 'inactiva', 'secondary'],
    ]
  end

  scope :for_statuses, ->(values) do
    return all if values.blank?
    where(status: statuses.values_at(*Array(values)))
  end

  scope :by_bedroom, ->(ids_ary) { where(bedroom_id: ids_ary) }

  # Assign a certain patient to the bed
  def assign_patient(a_patient)
    raise ArgumentError, 'Cama ocupada' unless self.disponible?
    self.patient = a_patient
    self.ocupada!
  end

  # Remve a certain patient from the bed
  def remove_patient(a_patient)
    raise ArgumentError, 'El paciente no corresponde al que desea liberar' if self.patient != a_patient
    self.patient = nil
    self.disponible!
  end
end
