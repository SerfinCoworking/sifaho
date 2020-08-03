class ReceiptProduct < ApplicationRecord
  belongs_to :receipt
  belongs_to :supply, -> { with_deleted }
  belongs_to :supply_lot, -> { with_deleted }, optional: true
  belongs_to :sector_supply_lot, -> { with_deleted }, optional: true

  # Validaciones
  validates_presence_of :receipt, :supply, :lot_code, :laboratory_name, :expiry_date
end
