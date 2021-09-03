json.extract! inpatient_prescription_product, :id, :inpatient_prescription_id, :product_id, :dose_quantiity, :interval, :status, :observation, :dispensed_by_id, :created_at, :updated_at
json.url inpatient_prescription_product_url(inpatient_prescription_product, format: :json)
