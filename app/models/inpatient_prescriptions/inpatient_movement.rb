class InpatientMovement < ApplicationRecord
  
  # Relationships
  belongs_to :bed
  has_one :bedroom, through: :bed
  has_one :establishment, through: :bedroom
  belongs_to :patient
  belongs_to :movement_type, class_name: 'InpatientMovementType'
  belongs_to :user

  # Validations
  validates_presence_of :bed_id, :patient_id, :movement_type, :user
  validate :admit_patient, if: :is_admission?

  # Delegations
  delegate :name, to: :movement_type, prefix: true
  delegate :name, to: :bedroom, prefix: true
  delegate :name, to: :bed, prefix: true
  delegate :fullname, :dni, :age_string, to: :patient, prefix: true

  # Callbacks
  before_create :apply_movement
  
  # Scopes
  scope :establishment, -> (establishment_id) {
    left_joins(:establishment).where("establishments.id = ?" , establishment_id)
  }

  scope :admissions, -> { where(movement_type_id: 1) }

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

  scope :since_date, ->(a_date) { where("inpatient_movements.created_at >= ?", a_date) }

  def is_admission?
    self.movement_type_id == 1
  end

  private

  # Apply the inpatient movement depending the movement type
  def apply_movement
    if self.movement_type_id == 1 # Ingreso
      self.bed.assign_patient(self.patient)
    elsif self.movement_type_id == 2 # Egreso
      self.bed.remove_patient(self.patient)
    elsif self.movement_type_id == 3 # Traspaso
      self.bed.remove_patient(self.patient)
      self.bed.assign_patient(self.patient)
    end
  end

  def admit_patient
    if self.patient.present? && self.patient.bed.present?
      errors.add(:patient_id, "DNI #{self.patient.dni} ya se encuentra hospitalizado en la cama #{self.patient.bed.name}")
    end
  end
end
