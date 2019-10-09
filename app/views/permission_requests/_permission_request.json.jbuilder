json.extract! permission_request, :id, :user_id, :status, :observation, :created_at, :updated_at
json.url permission_request_url(permission_request, format: :json)
