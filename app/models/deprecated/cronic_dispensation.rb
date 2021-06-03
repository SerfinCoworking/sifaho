class CronicDispensation < ApplicationRecord
  belongs_to :prescription, -> { with_deleted }
  has_many :quantity_ord_supply_lots, dependent: :destroy

  scope :newest_first, -> { order(created_at: :desc) }
end
