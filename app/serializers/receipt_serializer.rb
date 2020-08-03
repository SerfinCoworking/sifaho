class ReceiptSerializer < ActiveModel::Serializer
  attributes :id, :lot_code, :laboratory_name, :expiry_date, :quantity, :code
  has_one :supply
  has_one :supply_lot
end
