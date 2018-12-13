class Sector < ApplicationRecord
  # Relaciones
  belongs_to :establishment
  has_many :users
  has_many :sector_supply_lots, -> { with_deleted }
  has_many :supply_lots, -> { with_deleted }, through: :sector_supply_lots
  has_many :supplies, -> { with_deleted.distinct }, through: :supply_lots
  has_many :user_sectors
  has_many :users, :through => :user_sectors

  # Validaciones
  validates_presence_of :name
  validates_presence_of :complexity_level

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
end
