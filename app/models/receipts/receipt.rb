class Receipt < ApplicationRecord
  include PgSearch::Model

  enum status: { auditoria: 0, recibido: 1}

  # Relationships
  belongs_to :provider_sector, class_name: 'Sector'
  belongs_to :applicant_sector, class_name: 'Sector'
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true
  has_one :provider_establishment, through: :provider_sector, source: :establishment
  has_one :applicant_establishment, through: :applicant_sector, source: :establishment
  has_many :receipt_products
  has_many :supplies, through: :receipt_products
  has_many :movements, class_name: 'ReceiptMovement'
  has_many :stock_movements, as: :order, dependent: :destroy, inverse_of: :order

  # Validations
  validates_presence_of :provider_sector_id, :applicant_sector, :code
  validates_uniqueness_of :code
  validate :validate_receipt_products_length
  validates_associated :receipt_products

  # Delegations
  delegate :sector_and_establishment, to: :applicant_sector, prefix: :applicant
  delegate :sector_and_establishment, to: :provider_sector, prefix: :provider

  # Nested attributes
  accepts_nested_attributes_for :receipt_products,
                                reject_if: proc { |attributes| attributes['product_id'].blank? },
                                allow_destroy: true

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
                  against: :code,
                  using: { tsearch: { prefix: true } },
                  ignoring: :accents

  pg_search_scope :search_provider,
                  associated_against: { provider_sector: :name, provider_establishment: :name },
                  using: { tsearch: { prefix: true } },
                  ignoring: :accents

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = sort_option =~ /desc$/ ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("receipts.created_at #{direction}")
    when /^responsable_/
      # Ordenamiento por nombre de responsable
      order("LOWER(responsable.username) #{direction}").joins("INNER JOIN users as responsable ON responsable.id = receipts.responsable_id")
    when /^sector_/
      # Ordenamiento por nombre de sector
      order("sectors.name #{direction}").joins(:sector)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("receipts.status #{direction}")
    when /^tipo_/
      # Ordenamiento por nombre de estado
      order("receipts.order_type #{direction}")
    when /^ins_/
      # Ordenamiento por nombre de insumo solicitado
      order("quantity_ord_supply_lots.count #{direction}")
    when /^solicitado_/
      # Sort by requested date
      order("receipts.requested_date #{direction}")
    when /^recibido_/
      # Sort by date received
      order("receipts.date_received #{direction}")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{sort_option.inspect}")
    end
  }

  scope :with_status, lambda { |a_status|
    where('receipts.status = ?', a_status)
  }

  scope :received_date_since, lambda { |a_date|
    where('received_date >= ?', a_date)
  }

  scope :received_date_to, lambda { |a_date|
    where('received_date <= ?', a_date)
  }

  scope :since_date, lambda { |a_date|
    where('receipts.created_at >= ?', a_date)
  }

  scope :to_date, lambda { |a_date|
    where('receipts.created_at <= ?', a_date)
  }

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Sector (a-z)', 'sector_asc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recibido (asc)', 'recibido_desc']
    ]
  end

  def self.options_for_status
    [
      ['Recibo auditoria', 6, 'warning'],
      ['Recibo realizado', 7, 'success']
    ]
  end

  # Cambia estado del pedido a "Paquete recibido" y se reciben los lotes
  def receive_remit(a_user)
    if self.auditoria?
      if self.receipt_products.where.not(lot_code: nil).exists?
        self.status = 'recibido'
        receipt_products.each { |r_product| r_product.increment_new_lot_to(a_user.sector) }
        self.received_date = DateTime.now
        self.received_by = a_user
        self.save!
      else
        raise ArgumentError, 'No hay productos para recibir en el pedido'
      end # End check if sector supply exists
    else 
      raise ArgumentError, 'El pedido está en'+ self.status.split('_').map(&:capitalize).join(' ')
    end
  end

  def validate_receipt_products_length
    errors.add(:receipt_products_legnth, "Debe agregar almenos 1 producto") if self.receipt_products.size < 1
  end

  def create_notification(of_user, action_type)
    ReceiptMovement.create(user: of_user, receipt: self, action: action_type, sector: of_user.sector)
    (self.applicant_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: "recibo", action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
    (self.provider_sector.users.uniq - [of_user]).each do |user|
      @not = Notification.where( actor: of_user, user: user, target: self, notify_type: "recibo", action_type: action_type, actor_sector: of_user.sector ).first_or_create
      @not.updated_at = DateTime.now
      @not.read_at = nil
      @not.save
    end
  end

  def self.applicant(a_sector)
    where(applicant_sector: a_sector)
  end

  def self.provider(a_sector)
    where(provider_sector: a_sector)
  end

  # Returns the name of the efetor who deliver the products
  def origin_name
    "#{provider_sector.name} #{provider_establishment.short_name || ''}"
  end

  # Returns the name of the efetor who receive the products
  def destiny_name
    "#{applicant_sector.name} #{applicant_establishment.short_name || ''}"
  end

  # Return the i18n model name
  def human_name
    self.class.model_name.human
  end

  def remit_code
    self.code
  end
end
