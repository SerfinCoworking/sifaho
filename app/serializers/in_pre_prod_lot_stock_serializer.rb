class InPreProdLotStockSerializer < ActiveModel::Serializer
  attributes :id, :quantity
  has_one :inpatient_prescription_product
  has_one :lot_stock
  has_one :dispensed_by
end
