class OrderingSupplyMovement < ApplicationRecord
  belongs_to :user
  belongs_to :ordering_supply
  belongs_to :sector
end
