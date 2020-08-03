json.extract! receipt, :id, :supply_id, :supply_lot_id, :lot_code, :laboratory_name, :expiry_date, :quantity, :code, :created_at, :updated_at
json.url receipt_url(receipt, format: :json)
