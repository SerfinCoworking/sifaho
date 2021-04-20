json.extract! inpatient_prescription, :id, :patient_id, :professional_id, :bed_id, :remit_code, :observation, :status, :date_prescribed, :created_at, :updated_at
json.url inpatient_prescription_url(inpatient_prescription, format: :json)
