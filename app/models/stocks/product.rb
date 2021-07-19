class Product < ApplicationRecord
  include PgSearch

  # Relations
  belongs_to :unity
  belongs_to :area
  belongs_to :snomed_concept, optional: true
  has_many :stocks, dependent: :destroy
  has_many :external_order_product
  has_many :patient_product_state_reports

  # Validations
  validates_presence_of :name, :code, :area_id, :unity_id
  validates_uniqueness_of :code

  # Delegations
  delegate :name, to: :area, prefix: true
  delegate :name, to: :unity, prefix: true
  delegate :term, :fsn, :concept_id, :semantic_tag, to: :snomed_concept, prefix: :snomed, allow_nil: true

  filterrific(
    default_filter_params: { sorted_by: 'nombre_asc' },
    available_filters: [
      :search_code,
      :search_name,
      :with_area_ids,
      :sorted_by,
    ]
  )

  # To filter records by controller params
  # Slice params "search_code, search_name, with_area_ids"
  def self.filter(params)
    @products = self.all
    @products = params[:search_code].present? ? self.search_code( params[:search_code] ) : @products
    @products = params[:search_name].present? ? self.search_name( params[:search_name] ) : @products
    @products = params[:with_area_ids].present? ? self.with_area_ids( params[:with_area_ids] ) : @products
  end

  # Scopes
  pg_search_scope :search_code,
    against: :code,
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_name,
    against: :name,
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^codigo_/
      # Ordenamiento por id de insumo
      order("products.code::integer #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de insumo
      order("LOWER(products.name) #{ direction }")
    when /^unidad_/
      # Ordenamiento por la unidad
      # order("LOWER(unities.name) #{ direction }").joins(:unity)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_sorted_by
    [
      ['Código (menor primero)', 'codigo_asc'],
      ['Código (mayor primero)', 'codigo_desc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Nombre (z-a)', 'nombre_desc']
    ]
  end

  scope :with_code, lambda { |product_code|
    where('products.code = ?', product_code)
  }
  
  scope :with_area_ids, ->(area_ids) { where(area_id: area_ids) }

  def self.search_supply(a_name)
    Supply.search_text(a_name).with_pg_search_rank
  end
end
