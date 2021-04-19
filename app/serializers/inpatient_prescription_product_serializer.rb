class InpatientPrescriptionProductSerializer < ActiveModel::Serializer
  attributes :id, :dose_quantiity, :interval, :status, :observation
  has_one :inpatient_prescription
  has_one :product
  has_one :dispensed_by
end
