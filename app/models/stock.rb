class Stock < ApplicationRecord
  include PgSearch

  # Relations
  belongs_to :supply
  belongs_to :sector
  has_many :sector_supply_lots

  
  def calc_stock_quantity
    self.quantity = self.sector_supply_lots.sum(:quantity)
    self.save
  end

  filterrific(
    default_filter_params: { sorted_by: 'codigo_asc' },
    available_filters: [
      :sorted_by,
      :search_supply,
      :search_lot,
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("stocks.created_at #{ direction }")
    when /^codigo_/
      # Ordenamiento por id de insumo
      order("supplies.code #{ direction }").joins(:supplies)
    when /^nombre_/
      # Ordenamiento por nombre de insumo
      order("LOWER(supplies.name) #{ direction }").joins(:supplies)
    when /^unidad_/
      # Ordenamiento por la unidad
      order("LOWER(supplies.unity) #{ direction }").joins(:supplies)
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
