class Receipt < ApplicationRecord
  belongs_to :supply
  belongs_to :supply_lot
end
