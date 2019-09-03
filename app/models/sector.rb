class Sector < ApplicationRecord
  # Relaciones
  belongs_to :establishment
  has_many :users
  has_many :sector_supply_lots, -> { with_deleted }
  has_many :supply_lots, -> { with_deleted }, through: :sector_supply_lots
  has_many :supplies, -> { with_deleted.distinct }, through: :supply_lots
  has_many :user_sectors
  has_many :users, :through => :user_sectors
  has_many :reports, dependent: :destroy
 
  has_many :provider_ordering_supplies, foreign_key: "provider_sector_id", class_name: "OrderingSupply"
  has_many :provider_ordering_quantity_supplies, through: :provider_ordering_supplies, source: "quantity_ord_supply_lots"
 
  has_many :provider_internal_supplies, foreign_key: "provider_sector_id", class_name: "InternalOrder" 
  has_many :provider_internal_quantity_supplies, through: :provider_internal_supplies, source: "quantity_ord_supply_lots"
 
  has_many :provider_prescriptions, foreign_key: "provider_sector_id", class_name: "Prescription"
  has_many :provider_prescription_quantity_supplies, through: :provider_prescriptions, source: "quantity_ord_supply_lots"
  
  # Validaciones
  validates_presence_of :name, :complexity_level

  delegate :name, to: :establishment, prefix: :establishment

  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end

  scope :with_establishment_id, lambda { |an_id|
    where(establishment_id: [*an_id])
  }

  def establishment_name
    self.establishment.name
  end

  def sector_and_establishment
    self.name+' de '+self.establishment.name
  end

  def sum_delivered_ordering_supply_quantities_to(a_supply, since_date, to_date)
    self.provider_ordering_quantity_supplies.where(supply: a_supply).entregado
      .dispensed_since(since_date)
      .dispensed_to(to_date).sum(:delivered_quantity)
  end

  def sum_delivered_prescription_quantities_to(a_supply, since_date, to_date)
    self.provider_prescription_quantity_supplies.where(supply: a_supply).entregado
      .dispensed_since(since_date)
      .dispensed_to(to_date).sum(:delivered_quantity)
  end

  def sum_delivered_internal_quantities_to(a_supply, since_date, to_date)
      self.provider_internal_quantity_supplies.where(supply: a_supply).entregado
        .dispensed_since(since_date)
        .dispensed_to(since_date)
        .sum(:delivered_quantity)
  end

  def delivered_ordering_supply_quantities_by_establishment_to(a_supply)
    self.provider_ordering_quantity_supplies
      .where(supply: a_supply)
      .entregado
      .group(:quantifiable_id, :quantifiable_type).order("sum_amount DESC")
      .select(:quantifiable_id, :quantifiable_type, "SUM(delivered_quantity) as sum_amount")
  end
end