json.extract! prescription, :id, :observation, :date_received, :date_processed, :professional_id, :patient_id, :prescription_status_id, :created_at, :updated_at
json.url prescription_url(prescription, format: :json)
