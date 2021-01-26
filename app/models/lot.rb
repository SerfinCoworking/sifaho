class Lot < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  enum status: { vigente: 0, por_vencer: 1, vencido: 2 }

  #callback
  after_validation :update_status

  # Relations
  belongs_to :product
  belongs_to :laboratory
  has_many :lot_stocks

  # Validations
  # validates_presence_of :product, :laboratory, :code

  validates :product, 
    uniqueness: { :scope => [:laboratory_id, :code],
    unless: :expire?,
    message: ->(object, data) do
      "El lote #{object.code}!, ya existe con ese laboratorio! Intenta con otro!"
    end
  }

  validates :product,
    uniqueness: { :scope => [:laboratory_id, :code, :expiry_date], 
    if: :expire?,
    message: ->(object, data) do
      "El lote #{object.code} ya existe con ese laboratorio y fecha de vencimiento! Intenta con otro!"
    end
  }

  # Delegations
  delegate :name, :code, to: :product, prefix: true
  delegate :name, to: :laboratory, prefix: true

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
      order("lots.code::integer #{ direction }")
    when /^codigo_producto_/
      # Order by product code
      order("products.code::integer #{ direction }")
    when /^producto_/
      # Order by product name
      order("LOWER(products.name) #{ direction }")
    when /^laboratorio_/
      # Order by laboratory name
      order("LOWER(laboratories.name) #{ direction }").joins(:laboratory)
    when /^creado_/s
      # Order by lot created date
      order("lots.created_at #{ direction }")
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
  
  # Métodos privados #----------------------------------------------------------
  private
  
  # Se actualiza el estado de expiración sin guardar
  def update_status
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
