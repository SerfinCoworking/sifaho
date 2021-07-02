class InpatientPrescriptionSerializer < ActiveModel::Serializer
  attributes :id, :remit_code, :observation, :status, :date_prescribed
  has_one :patient
  has_one :professional
  has_one :bed
end
