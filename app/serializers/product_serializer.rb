class ProductSerializer < ActiveModel::Serializer
  attributes :id, :code, :name, :description, :observation
  has_one :unity
end
