class Professional < ApplicationRecord
  include PgSearch
  
  enum sex: { indeterminate: 1, female: 2, male: 3 }

  after_create :assign_full_name

  # Relaciones
  has_many :outpatient_prescriptions
  has_many :chronic_prescriptions
  has_many :qualifications
  belongs_to :professional_type, optional: true
  has_one :user
  has_one_attached :avatar

  # Validaciones
  validates_presence_of :first_name, :last_name
  validates :dni, uniqueness: true, if: -> { dni.present? }

  accepts_nested_attributes_for :qualifications,
                                allow_destroy: true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_professional,
      :search_professional_qualification,
      :get_by_qualifications_and_fullname,
      :search_dni,
      :with_professional_type_id,
    ]
  )

  pg_search_scope :get_by_qualifications_and_fullname,
    against: [:last_name, :first_name],
    :associated_against => { qualifications: :code },
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_professional_qualification,
    :associated_against => { qualifications: :code },
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_professional,
    against: [:first_name, :last_name],
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("professionals.created_at #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre del profesional
      order("LOWER(professionals.first_name) #{ direction }")
    when /^apellido_/
      # Ordenamiento por apellido del profesional
      order("LOWER(professionals.last_name) #{ direction }")
    when /^matricula_/
      # Ordenamiento por matricula
      order("LOWER(qualifications.code) #{ direction }").joins(:qualifications)
    when /^professional_type_/
      # Ordenamiento por nombre del sector
      order("LOWER(professional_types.name) #{ direction }").joins(:professional_type)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :search_dni, lambda { |query|
    string = query.to_s
    where('professionals.dni::text LIKE ?', "%#{string}%")
  }
  
  scope :without_user_asigned, -> { where(user_id: :nil) }

  def qualifications_attributes=(attributes)
    attributes.each do |attr|
      qualification = Qualification.find_by(code: attr[:code])
      attr[:id] = qualification.id if qualification.present?
    end
    super
  end

  def full_name
    self.fullname
  end

  def full_info
    self.fullname+" MP "+self.qualifications.first.code
  end

  # filters on 'sector_id' foreign key
  scope :with_professional_type_id, lambda { |type_id|
    where(professional_type_id: [*type_id])
  }

  def assign_full_name
    self.fullname = self.last_name+" "+self.first_name
    save!
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación', 'created_at_asc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Apellido (a-z)', 'apellido_asc'],
      ['Matricula', 'matricula_asc'],
      ['Sector', 'sector_asc'],
    ]
  end
end
