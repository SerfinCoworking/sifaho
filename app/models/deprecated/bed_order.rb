class BedOrder < ApplicationRecord
  acts_as_paranoid
  include PgSearch::Model

  enum order_type: { provision: 0, solicitud: 1 }

  enum status: { borrador: 0, pendiente: 1, en_camino: 3, entregada: 4, anulada: 5 }

  # Relaciones
  belongs_to :bed
  belongs_to :patient
  belongs_to :establishment
  belongs_to :applicant_sector, class_name: 'Sector'
  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots, dependent: :destroy
  has_many :supply_lots, -> { with_deleted }, :through => :sector_supply_lots
  has_many :supplies, -> { with_deleted }, :through => :quantity_ord_supply_lots
  has_many :movements, class_name: "BedOrderMovement"

  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :sent_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true
  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :sent_request_by, class_name: 'User', optional: true

  # Validaciones
  validates_presence_of :patient, :bed, :quantity_ord_supply_lots, :remit_code, :establishment
  validates_associated :quantity_ord_supply_lots, :sector_supply_lots
  validates_uniqueness_of :remit_code, conditions: -> { with_deleted } 

  # Atributos anidados
  accepts_nested_attributes_for :quantity_ord_supply_lots,
    :reject_if => :all_blank,
    :allow_destroy => true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_code,
      :search_patient,
      :search_bed,
      :with_order_type,
      :with_status,
      :requested_date_since,
      :requested_date_to,
      :sorted_by
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("bed_orders.created_at #{ direction }")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de sector
      order("supplies.name #{ direction }").joins(:supplies)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("bed_orders.status #{ direction }")
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("bed_orders.date_received #{ direction }")
    when /^entregado_/
      # Ordenamiento por la fecha de dispensación
      order("bed_orders.date_delivered #{ direction }")
    elseforeign_keyforeign_key
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  def self.establishment(a_establishment)
    where(establishment: a_establishment)
  end

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Borrador', 0, 'warning'],
      ['Pendiente', 1, 'info'],
      ['En camino', 2, 'primary'],
      ['Entregada', 3, 'success'],
      ['Anulada', 5, 'danger'],
    ]
  end

  def bedroom_name
    self.bed.bedroom.name
  end

  def bed_name
    self.bed.name
  end

  def create_notification(of_user, action_type)
    BedOrderMovement.create(user: of_user, bed_order: self, action: action_type, sector: of_user.sector)
    (of_user.sector.users.uniq - [of_user]).each do |user|
      Notification.create( actor: of_user, user: user, target: self, notify_type: "provisión", action_type: action_type, actor_sector: of_user.sector )
    end
    (self.bed.service.users.uniq - [of_user]).each do |user|
      Notification.create( actor: of_user, user: user, target: self, notify_type: "provisión", action_type: action_type, actor_sector: of_user.sector )
    end
  end
end
