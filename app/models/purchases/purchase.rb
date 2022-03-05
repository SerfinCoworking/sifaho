class Purchase < ApplicationRecord
  include PgSearch::Model

  enum status: { inicial: 0,  auditoria: 1, recibido: 2}
    
  belongs_to :provider_sector, class_name: 'Sector'
  belongs_to :applicant_sector, class_name: 'Sector'
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true
  has_one :provider_establishment, :through => :provider_sector, :source => :establishment
  has_one :applicant_establishment, :through => :applicant_sector, :source => :establishment
  has_many :movements, class_name: "PurchaseMovement"
  has_many :purchase_products, dependent: :destroy, inverse_of: 'purchase'
  has_many :products, :through => :purchase_products
  has_many :stock_movements, as: :order, dependent: :destroy, inverse_of: :order
  
  has_many :purchase_areas
  has_many :areas, through: :purchase_areas 

  # Validaciones
  validates_presence_of :provider_sector_id, :applicant_sector_id, :code_number
  # debemos agregar condicion solo para que corra esta validacion solo si se encuentra 
  # en el paso de carga de productos, 
  # agregar estado inicial a la compra (este indica el salto de validacion de productos)
  validate :presence_of_products_into_the_order, if: :is_not_inicial?
  validates :code_number, uniqueness: true
  validates_associated :purchase_products

  # Atributos anidados
  accepts_nested_attributes_for :purchase_products,
  :allow_destroy => true
  
  accepts_nested_attributes_for :areas,
  :allow_destroy => true

  # Callbacks
  before_validation :record_remit_code, on: :create
  
  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_code,
      :search_provider,
      :received_date_since,
      :received_date_to,
      :with_status,
      :sorted_by
    ]
  )

  pg_search_scope :search_code,
    :against => :remit_code,
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.
  
  pg_search_scope :search_provider,
    :associated_against => { :provider_sector => :name, :provider_establishment => :name },
    :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("purchases.created_at #{ direction }")
    when /^responsable_/
      # Ordenamiento por nombre de responsable
      order("LOWER(responsable.username) #{ direction }").joins("INNER JOIN users as responsable ON responsable.id = purchases.responsable_id")
    when /^sector_/
      # Ordenamiento por nombre de sector
      order("sectors.name #{ direction }").joins(:sector)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("purchases.status #{ direction }")
    when /^tipo_/
      # Ordenamiento por nombre de estado
      order("purchases.order_type #{ direction }")
    when /^ins_/
      # Ordenamiento por nombre de insumo solicitado
      order("quantity_ord_supply_lots.count #{ direction }")
    when /^solicitado_/
      # Ordenamiento por la fecha de recepción
      order("purchases.requested_date #{ direction }") 
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("purchases.date_received #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_status, lambda { |a_status|
    where('purchases.status = ?', a_status)
  }

  scope :received_date_since, lambda { |a_date|
    where('received_date >= ?', a_date)
  }

  scope :received_date_to, lambda { |a_date|
    where('received_date <= ?', a_date)
  }

  # Si es estado inicial, debemos solo guardar los campos requeridos
  def is_not_inicial?
    return !self.inicial?
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Sector (a-z)', 'sector_asc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recibido (asc)', 'recibido_desc'],
    ]
  end

  def self.options_for_status
    [
      ['Recibo auditoria', 6, 'warning'],
      ['Recibo realizado', 7, 'success']
    ]
  end

  # Cambia estado del pedido a "Paquete recibido" y se reciben los lotes
  def receive_remit_by(a_user)
    self.purchase_products.each do |purchase_product|
      purchase_product.increment_lot_stock_to(self.applicant_sector)
    end

    self.received_date = DateTime.now
    self.create_notification(a_user, "recibió")
    self.recibido!
    
  end

  def create_notification(of_user, action_type)
    PurchaseMovement.create(user: of_user, purchase: self, action: action_type, sector: of_user.sector)
    (self.applicant_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: "abastecimiento", action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
    (self.provider_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: "abastecimiento", action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  def return_to_audit(a_user)
    # primero actualizamos los totales de la dosis de cada producto original recetado
    self.purchase_products.each do | cpp |
      cpp.decrement_stock
    end

    self.auditoria!
    self.create_notification(a_user, "retorno un remito")
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    self.provider_sector.name
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    self.applicant_sector.name
  end

  # Return the i18n model name
  def human_name
    self.class.model_name.human
  end
  
  private

  def record_remit_code
    self.remit_code = "AB"+DateTime.now.to_s(:number)
  end

  def presence_of_products_into_the_order
    if self.purchase_products.size == 0
      errors.add(:presence_of_products_into_the_order, "Debe agregar almenos 1 producto")      
    end
  end
end
