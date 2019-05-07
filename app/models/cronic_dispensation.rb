class CronicDispensation < ApplicationRecord
  belongs_to :prescription
  has_many :quantity_ord_supply_lots
end
