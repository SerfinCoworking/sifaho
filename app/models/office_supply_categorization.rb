class OfficeSupplyCategorization < ApplicationRecord
  # Relaciones
  belongs_to :office_supply
  belongs_to :category

  # Validaciones
  validates_presence_of :office_supply, :category, :position
  validates_uniqueness_of :position, :scope => :office_supply_id
  validates_uniqueness_of :category_id, :scope => :office_supply_id
end
