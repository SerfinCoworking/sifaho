class InpatientMovement < ApplicationRecord
  
  # Relationships
  has_one :establishment, through: :bed
  belongs_to :bed
  belongs_to :patient
  belongs_to :movement_type, class_name: 'InpatientMovementType'
  belongs_to :user

  # Validations
  validates :bed, :patient, :movement_type, :user, :observations, presence: true

  # Callbacks
  before_validation :assign_description

  # Scopes
  scope :establishment, -> (establishment_id) {
    joins(:bed).where(bed: { establishment_id: establishment_id }) 
  }

  filterrific(
    default_filter_params: { sorted_by: 'fecha_desc' },
    available_filters: [
      :sorted_by,
      :by_type
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^fecha_/
      # Ordenamiento por fecha de creación
      reorder("created_at #{ direction }")
    when /^cama_/
      # Ordenamiento por nombre de estado
      reorder("beds.name #{ direction }").joins(:bed)
    when /^paciente_/
      # Ordenamiento por nombre de estado
      reorder("inpatient_movements.status #{ direction }")
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

  scope :by_type, ->(ids_ary) { where(movement_type_id: ids_ary) }
end
