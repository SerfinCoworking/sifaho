class Area < ApplicationRecord
  include PgSearch::Model

  # Relations
  belongs_to :parent, class_name: 'Area', optional: true
  has_many :subareas, class_name: 'Area', foreign_key: :parent_id, dependent: :destroy
  has_many :products

  # Validations
  validates_presence_of :name

  delegate :name, to: :parent, prefix: true, allow_nil: true

  # Scopes
  scope :main, -> { where(parent_id: nil) }

  pg_search_scope :search,
    against: [:name],
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  filterrific(
    default_filter_params: { sorted_by: 'nombre_asc' },
    available_filters: [
      :search,
      :sorted_by,
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^nombre_/
      # Ordenamiento por el nombre del producto
      reorder("areas.name #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_sorted_by
    [
      ['Nombre (a-z)', 'nombre_asc'],
      ['Nombre (z-a)', 'nombre_desc'],
    ]
  end
  
  def self.filter(params)
    @areas = self.all
    @areas = params[:name].present? ? self.search( params[:name] ) : @areas
  end

  def all_nested_products
    @all_products = self.products
    self.subareas.each do |subarea|
      @all_products += subarea.products
    end
    return @all_products
  end
end
