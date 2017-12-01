json.extract! prescription, :id, :observation, :date_received, :date_processed, :id_professional_grantor_id, :id_patient_id, :id_prescription_status_id, :created_at, :updated_at
json.url prescription_url(prescription, format: :json)
