class Lot < ApplicationRecord
  acts_as_paranoid
  include PgSearch::Model

  enum status: { vigente: 0, por_vencer: 1, vencido: 2 }

  # Relationships
  belongs_to :product
  belongs_to :laboratory
  belongs_to :provenance, class_name: 'LotProvenance', counter_cache: :lots_count, optional: true
  has_many :lot_stocks

  # Callbacks
  after_validation :update_status

  # Validations
  validates_presence_of :provenance_id
  validates :product,
    uniqueness: { :scope => [:provenance_id, :laboratory_id, :code, :expiry_date], 
    if: :expire?,
    message: ->(object, data) do
      "El lote #{object.code} ya existe con esa procedencia, laboratorio y fecha de vencimiento! Intenta con otro!"
    end
  }

  # Delegations
  delegate :name, :code, :area_name, :unity_name, to: :product, prefix: true
  delegate :name, to: :laboratory, prefix: true
  delegate :name, to: :provenance, prefix: true

   filterrific(
    default_filter_params: { sorted_by: 'creado_asc' },
    available_filters: [
      :sorted_by,
      :search_lot_code,
      :search_product_code,
      :search_product,
      :search_laboratory,
    ]
  )

  # Scopes
  pg_search_scope :search_lot_code,
    against: :code,
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_product_code,
    :associated_against => {
      :product => :code
    },
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_product,
    :associated_against => {
      :product => :name
    },
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_laboratory,
    :associated_against => {
      :laboratory => :name
    },
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^codigo_lote_/
      # Order by lot code
      reorder("lots.code::integer #{ direction }")
    when /^codigo_producto_/
      # Order by product code
      reorder("products.code::integer #{ direction }")
    when /^estado_/
      # Order by product name
      reorder("lots.status #{ direction }")
    when /^producto_/
      # Order by product name
      reorder("LOWER(products.name) #{ direction }")
    when /^laboratorio_/
      # Order by laboratory name
      reorder("LOWER(laboratories.name) #{ direction }").joins(:laboratory)
    when /^vencimiento_/s
      # Order by lot created date
      reorder("lots.created_at #{ direction }")
    when /^creado_/s
      # Order by lot created date
      reorder("lots.created_at #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_product_code, lambda { |a_product_code| 
    joins(:product).where('products.code = ?', a_product_code)
  }

  scope :without_status, lambda { |a_status|
    where.not('status = ?', a_status )
  }

  def expire?
    expiry_date.present?
  end

  def expiry_date_string
    self.expire? ? self.expiry_date.strftime("%d/%m/%Y") : ''
  end

  def short_expiry_date_string
    self.expire? ? self.expiry_date.strftime("%m/%y") : ''
  end

  # Se actualiza el estado de expiración sin guardar
  def update_status
    puts self.id
    unless self.vencido?
      if self.expiry_date.present?
        # If expired
        if self.expiry_date <= DateTime.now
          self.status = "vencido"
          # If near_expiry
        elsif expiry_date < DateTime.now + 3.month && expiry_date > DateTime.now
          self.status = "por_vencer"
          # If good
        elsif expiry_date > DateTime.now
          self.status = "vigente"
        end
      end
    end
  end
end
