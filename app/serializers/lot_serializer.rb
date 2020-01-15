class LotSerializer < ActiveModel::Serializer
  attributes :id, :code, :expiry_date
  has_one :product
  has_one :laboratory
end
