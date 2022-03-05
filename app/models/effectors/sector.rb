class Sector < ApplicationRecord
  include PgSearch::Model

  # Relaciones
  belongs_to :establishment, counter_cache: true
  belongs_to :establishment, counter_cache: :sectors_count
  has_many :sector_supply_lots, -> { with_deleted }
  has_many :supply_lots, -> { with_deleted }, through: :sector_supply_lots

  has_many :lot_stocks
  has_many :lots, -> { with_deleted }, through: :lot_stocks
  has_many :stocks

  has_many :supplies, -> { with_deleted.distinct }, through: :supply_lots
  has_many :user_sectors
  has_many :users, through: :user_sectors
  has_many :reports, dependent: :destroy
  has_many :stocks
  has_many :beds, foreign_key: :service_id
  has_many :applicant_internal_orders, class_name: 'InternalOrder', foreign_key: :applicant_sector_id
  has_many :provider_internal_orders, class_name: 'InternalOrder', foreign_key: :provider_sector_id
  has_many :applicant_external_orders, class_name: 'ExternalOrder', foreign_key: :applicant_sector_id
  has_many :provider_external_orders, class_name: 'ExternalOrder', foreign_key: :provider_sector_id

  # has_many :provider_external_orders, foreign_key: "provider_sector_id", class_name: "ExternalOrder"
  # has_many :provider_ordering_quantity_supplies, through: :provider_external_orders, source: "quantity_ord_supply_lots"

  # has_many :provider_internal_supplies, foreign_key: "provider_sector_id", class_name: "InternalOrder"
  # has_many :provider_internal_quantity_supplies, through: :provider_internal_supplies, source: "quantity_ord_supply_lots"

  # has_many :provider_prescriptions, foreign_key: "provider_sector_id", class_name: "Prescription"
  # has_many :provider_prescription_quantity_supplies, through: :provider_prescriptions, source: "quantity_ord_supply_lots"

  # Validaciones
  validates_presence_of :name, :establishment

  delegate :name, :short_name, to: :establishment, prefix: :establishment

  # SCOPES #--------------------------------------------------------------------
  pg_search_scope :search_name,
  against: :name,
  :using => {
    :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
  },
  :ignoring => :accents # Ignorar tildes.

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :search_name,
      :sorted_by,
    ]
  )

  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("sectors.created_at #{ direction }")
    when /^name_/s
      # Ordenamiento por fecha de creación en la BD
      order("sectors.name #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_establishment_id, lambda { |an_id|
    where(establishment_id: [*an_id])
  }

  scope :provide_hospitalization, -> { where(provide_hospitalization: true) }

  def establishment_name
    self.establishment.name
  end

  def sector_and_establishment
    self.name+' de '+self.establishment.name
  end

  def sum_delivered_external_order_quantities_to(a_supply, since_date, to_date)
    self.provider_ordering_quantity_supplies.where(supply: a_supply).entregado
      .dispensed_since(since_date)
      .dispensed_to(to_date)
      .sum(:delivered_quantity)
  end

  def sum_delivered_prescription_quantities_to(a_supply, since_date, to_date)
    self.provider_prescription_quantity_supplies.where(supply: a_supply).entregado
      .dispensed_since(since_date)
      .dispensed_to(to_date)
      .sum(:delivered_quantity)
  end

  def sum_delivered_internal_quantities_to(a_supply, since_date, to_date)
      self.provider_internal_quantity_supplies.where(supply: a_supply).entregado
        .dispensed_since(since_date)
        .dispensed_to(to_date)
        .sum(:delivered_quantity)
  end

  def delivered_external_order_quantities_by_establishment_to(a_supply)
    self.provider_ordering_quantity_supplies
      .where(supply: a_supply)
      .entregado
      .group(:quantifiable_id, :quantifiable_type).order("sum_amount DESC")
      .select(:quantifiable_id, :quantifiable_type, "SUM(delivered_quantity) as sum_amount")
  end

  def stock_to(product_id)
    stock = self.stocks
    .where(product_id: product_id)
    .select(:quantity)
    .first

    return stock.present? ? stock.quantity : 0    
  end
end
