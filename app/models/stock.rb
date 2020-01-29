class Stock < ApplicationRecord
  include PgSearch

  # Relations
  belongs_to :product
  belongs_to :sector
  has_many :sector_supply_lots
  has_one :area, through: :product
  has_one :unity, through: :product

  # Validations
  validates_presence_of :product, :sector

  # Delegations
  delegate :code, :name, :unity_name, :area_name, to: :product, prefix: true

  # Update the stock quantity 
  def update_stock
    self.quantity = self.sector_supply_lots.without_status(4).sum(:quantity)
    self.save
  end

  pg_search_scope :search_product_code,
    :associated_against => { :product => :code },
    :using => {:tsearch => { :prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_product_name,
    :associated_against => { :product => :name },
    :using => {:tsearch => { :prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.


  filterrific(
    default_filter_params: { sorted_by: 'codigo_asc' },
    available_filters: [
      :search_product_code,
      :search_product_name,
      :sorted_by,
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^modificado_/s
      # Ordenamiento por fecha de creación en la BD
      order("stocks.updated_at #{ direction }")
    when /^codigo_/
      # Ordenamiento por id de insumo
      order("products.code #{ direction }").joins(:product)
    when /^cantidad_/
      # Ordenamiento por la cantidad de stock
      order("stocks.quantity #{ direction }")
    when /^nombre_/
      # Ordenamiento por el nombre del producto
      order("LOWER(products.name) #{ direction }").joins(:product)
    when /^rubro_/
      # Ordenamiento por el rubro del producto
      order("LOWER(areas.name) #{ direction }").joins(:product, :area)
    when /^unidad_/
      # Ordenamiento por la unidad del prudcto
      order("LOWER(unities.name) #{ direction }").joins(:product, :unity)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :to_sector, lambda { |sector|
    where('stocks.sector_id = ?', sector.id)
  }
  
  def self.options_for_sorted_by
    [
      ['Código (asc)', 'codigo_asc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Unidad (a-z)', 'unidad_asc']
    ]
  end
end
