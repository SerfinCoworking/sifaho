class InternalOrderTemplateSerializer < ActiveModel::Serializer
  attributes :id, :name, :order_type
  has_one :owner_sector
  has_one :detination_sector
end
