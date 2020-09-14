class PatientProductReportSerializer < ActiveModel::Serializer
  attributes :id, :since_date, :to_date
  has_one :patient
  has_one :supply
  has_one :product
end
