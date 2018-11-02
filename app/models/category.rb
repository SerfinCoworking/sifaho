class Category < ApplicationRecord
  # Relaciones
  has_many :office_supply_categorizations
  has_many :office_supplies, :through => :office_supply_categorizations
end
