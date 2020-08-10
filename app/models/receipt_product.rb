class ReceiptProduct < ApplicationRecord
  belongs_to :receipt
  belongs_to :laboratory, optional: true
  belongs_to :supply, -> { with_deleted }
  belongs_to :supply_lot, -> { with_deleted }, optional: true
  belongs_to :sector_supply_lot, -> { with_deleted }, optional: true

  # Validaciones
  validates_presence_of :receipt, :supply_id, :lot_code, :expiry_date
end
