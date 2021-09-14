class UnifyProductSerializer < ActiveModel::Serializer
  attributes :id, :status, :observation
  has_one :origin_product
  has_one :target_product
end
