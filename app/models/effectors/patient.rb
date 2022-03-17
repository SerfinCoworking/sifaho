class Patient < ApplicationRecord
  include PgSearch::Model

  enum status: { Temporal: 0, Validado: 1 }
  enum sex: { Otro: 1, Femenino: 2, Masculino: 3 }
  enum marital_status: { soltero: 1, casado: 2, separado: 3, divorciado: 4, viudo: 5, otro: 6 }

  # Relationships
  belongs_to :patient_type, optional: true
  belongs_to :address, optional: true
  belongs_to :bed, optional: true
  has_many :outpatient_prescriptions, dependent: :destroy
  has_many :chronic_prescriptions, dependent: :destroy
  has_many :inpatient_prescriptions, dependent: :destroy
  has_one_base64_attached :avatar
  has_one_attached :file
  has_many :patient_phones, dependent: :destroy
  has_many :inpatient_movements

  # Validations
  validates_presence_of :first_name, :last_name, :dni
  validates_uniqueness_of :dni
  validates :dni, numericality: { only_integer: true }
  validates_associated :patient_phones

  # Delegations
  delegate :country_name, :state_name, :city_name, :line, to: :address, prefix: :address
  delegate :name, to: :patient_type, prefix: :patient_type

  accepts_nested_attributes_for :patient_phones,
                                reject_if: proc { |attributes| attributes['number'].blank? },
                                allow_destroy: true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_fullname,
      :search_dni,
      :with_patient_type_id,
    ]
  )

  pg_search_scope :get_by_dni_and_fullname,
                  against: %i[dni first_name last_name],
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  pg_search_scope :search_fullname,
                  against: %i[first_name last_name],
                  using: { tsearch: { prefix: true } }, # Buscar coincidencia desde las primeras letras.
                  ignoring: :accents # Ignorar tildes.

  scope :search_dni, lambda { |query|
    string = query.to_s
    where('dni::text LIKE ?', "%#{string}%")
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("patients.created_at #{ direction }")
    when /^nacimiento_/
      # Ordenamiento por fecha de creación en la BD
      order("patients.birthdate #{ direction }")
    when /^dni_/
      # Ordenamiento por fecha de creación en la BD
      order("patients.dni #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de paciente
      order("LOWER(patients.first_name) #{ direction }")
    when /^apellido_/
      # Ordenamiento por apellido de paciente
      order("LOWER(patients.last_name) #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_patient_type_id, lambda { |a_patient_type|
    where('patients.patient_type_id = ?', a_patient_type)
  }

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Apellido (a-z)', 'apellido_asc'],
    ]
  end

  def full_info
    "#{last_name} #{first_name} #{dni}"
  end

  def fullname
    self.last_name+", "+self.first_name
  end

  def age_string
    if self.birthdate.present?
      age = ((Time.zone.now - self.birthdate.to_time) / 1.year.seconds).floor
      age.to_s+" años"
    else
      "----"
    end
  end

  # Return formatted birthdate
  def birthdate_string
    self.birthdate.present? ? self.birthdate.strftime("%d/%m/%Y") : '---'
  end

  # Return the last hospitalization
  def last_hospitalization
    self.inpatient_movements.admissions.last
  end
end
