json.extract! external_order, :id, :sector_id, :observation, :date_received, :status, :created_at, :updated_at
json.url external_order_url(external_order, format: :json)
