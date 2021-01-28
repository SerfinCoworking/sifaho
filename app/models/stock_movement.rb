class StockMovement < ApplicationRecord
  belongs_to :order, polymorphic: true
  belongs_to :stock
  belongs_to :lot_stock

  delegate :destiny_name, :origin_name, :status, :human_name, to: :order, prefix: :order
end
