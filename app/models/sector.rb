class Sector < ApplicationRecord
  # Relaciones
  has_many :users
  has_many :internal_orders
  has_many :prescriptions

  # Validaciones
  validates_presence_of :sector_name
  validates_presence_of :complexity_level

  def self.options_for_select
    order('LOWER(sector_name)').map { |e| [e.sector_name, e.id] }
  end
end
