class StockSerializer < ActiveModel::Serializer
  attributes :id, :quantity
  has_one :supply
  has_one :sector
end
