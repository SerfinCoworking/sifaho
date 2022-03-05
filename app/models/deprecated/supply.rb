class Supply < ApplicationRecord
  acts_as_paranoid
  include PgSearch::Model

  # Relaciones
  has_many :reports, dependent: :destroy
  belongs_to :supply_area  
  has_many :quantity_ord_supply_lots
  has_many :prescriptions, -> { with_deleted },
  :through => :quantity_ord_supply_lots,
  :source => :quantifiable,
  :source_type => 'Prescription'
  
  has_many :internal_orders, -> { with_deleted },
  :through => :quantity_ord_supply_lots,
  :source => :quantifiable,
  :source_type => 'InternalOrder'

  has_many :bed_orders, -> { with_deleted },
  :through => :quantity_ord_supply_lots,
  :source => :quantifiable,
  :source_type => 'BedOrder'

  has_many :receipt_products
  has_many :receipts, -> { with_deleted }, :through => :receipt_products
  
  has_many :internal_order_template_supplies
  has_many :internal_order_template, through: :internal_order_template_supplies
  
  # Validaciones
  validates_presence_of :name, :unity, :supply_area
  validates_uniqueness_of :id

  filterrific(
    default_filter_params: { sorted_by: 'codigo_asc' },
    available_filters: [
      :with_code,
      :sorted_by,
      :search_supply,
      :with_area_id,
    ]
  )

  pg_search_scope :search_text,
    against: :name,
    :associated_against => {
      :supply_area => :name
    },
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
      order("supplies.id #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de insumo
      order("LOWER(supplies.name) #{ direction }")
    when /^unidad_/
      # Ordenamiento por la unidad
      order("LOWER(supplies.unity) #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_code, lambda { |query|
    string = query.to_s
    where('supplies.id::text LIKE ?', "#{string}%")
  }

  scope :with_area_id, lambda { |an_id|
    where('supplies.supply_area_id = ?', an_id)
  }

  def self.search_supply(a_name)
    Supply.search_text(a_name).with_pg_search_rank
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
   [
     ['Código (asc)', 'codigo_asc'],
     ['Nombre (a-z)', 'nombre_asc'],
     ['Unidad (a-z)', 'unidad_asc']
   ]
  end
end
