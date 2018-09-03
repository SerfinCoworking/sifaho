class Sector < ApplicationRecord
  # Relaciones
  belongs_to :establishment
  has_many :users
  has_many :internal_orders, -> { with_deleted }
  has_many :sector_supply_lots, -> { with_deleted }
  has_many :supply_lots, -> { with_deleted }, through: :sector_supply_lots

  # Validaciones
  validates_presence_of :sector_name
  validates_presence_of :complexity_level

  def self.options_for_select
    order('LOWER(sector_name)').map { |e| [e.sector_name, e.id] }
  end

  scope :with_establishment_id, lambda { |an_id|
    where(establishment_id: [*an_id])
  }

  def establishment_name
    self.establishment.name
  end

  def sector_and_establishment
    self.sector_name+' de '+self.establishment.name
  end
end
