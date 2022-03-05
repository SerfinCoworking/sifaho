class Establishment < ApplicationRecord
  include PgSearch::Model

  # Relationships
  has_many :sectors
  has_many :users, :through => :sectors
  has_many :prescriptions
  has_many :beds, through: :sectors
  has_many :hospitalized_patients, through: :beds, source: :patient
  has_many :inpatient_prescriptions, through: :hospitalized_patients
  belongs_to :city, optional: true
  belongs_to :sanitary_zone
  belongs_to :establishment_type

  has_one_attached :image

  # Validations
  validates_presence_of :name, :short_name
  validates :sanitary_zone_id, presence: true
  validates :cuie, allow_blank: true, length: { is: 6 }, uniqueness: true
  validates :establishment_type_id, presence: true
  validates :siisa,
    format: { with: /\A\d+\z/, message: "debe tener solo números." }
  validates :latitude , numericality: { greater_than_or_equal_to:  -90, less_than_or_equal_to: 90 }
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  # SCOPES #--------------------------------------------------------------------
  pg_search_scope :search_cuie,
    against: :cuie,
    :using => {
      :tsearch => { :prefix => true } # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_name,
    against: :name,
    :using => {
      :tsearch => { :prefix => true } # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  filterrific(
    default_filter_params: { sorted_by: 'sectores_desc' },
    available_filters: [
      :sorted_by,
      :search_cuie,
      :by_establishment_type,
      :search_name
    ]
  )

  scope :where_not_id, lambda { |an_id|
    where.not(id: [*an_id])
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^creado_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("establishments.created_at #{ direction }")
    when /^tipo_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("establishment_types.name #{ direction }").joins(:establishment_type)
    when /^nombre_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("establishments.name #{ direction }")
    when /^sectores_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("establishments.sectors_count #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_sorted_by
    [
      ["Nombre (a-z)", "nombre_asc"],
      ["Nombre (z-a)", "nombre_desc"],
      ["Creado (nueva primero)", "creado_desc"],
      ["Creado (antigua primero)", "creado_asc"],
      ["Sectores (mayor primero)", "sectores_asc"],
      ["Sectores (menor primero)", "sectores_desc"],
      ["Usuarios (mayor primero)", "usuarios_asc"],
      ["Usuarios (menor primero)", "usuarios_desc"],
    ]
  end

  scope :by_establishment_type, ->(ids_ary) { where(establishment_type: ids_ary) }

end
