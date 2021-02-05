class StockMovement < ApplicationRecord
  include PgSearch

  # Relations
  belongs_to :order, polymorphic: true
  belongs_to :stock
  belongs_to :lot_stock
  has_one :lot, through: :lot_stock

  # Delegations
  delegate :destiny_name, :origin_name, :status, :human_name, to: :order, prefix: :order


  filterrific(
    default_filter_params: { sorted_by: 'fecha_desc'},
    available_filters: [
      :search_lot,
      :since_date,
      :to_date,
      :sorted_by,
    ]
  )

  # Scopes

  pg_search_scope :search_lot,
    associated_against: { lot: [:code] },
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^fecha_/
      # Ordenamiento por fecha de recepción
      reorder("stock_movements.created_at #{ direction }")
    when /^lote_/
      # Order by lot
      reorder("lots.code #{ direction}").left_joins(:lot)
    when /^cantidad_/
      # Order by supplies count
      reorder("stock_movements.quantity #{ direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.options_for_sorted_by
    [
      ["Lote (a-z)", "lote_desc"],
      ["Lote (z-a)", "lote_asc"],
      ["Creado (nueva primero)", "fecha_desc"],
      ["Creado (antigua primero)", "fecha_asc"],
      ["Cantidad (mayor-menor)", "cantidad_asc"],
      ["Cantidad (menor-mayor)", "cantidad_desc"],
    ]
  end

  scope :since_date, lambda { 
    |a_date| where('stock_movements.created_at >= ?', DateTime.strptime(a_date, '%d/%m/%Y').beginning_of_day) 
  }

  scope :to_date, lambda { |a_date| where('stock_movements.created_at <= ?', DateTime.strptime(a_date, '%d/%m/%Y').end_of_day) }

  scope :to_stock_id, lambda { |an_id| where(stock_id: an_id) }
end
