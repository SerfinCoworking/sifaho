class OrderingSupplyComment < ApplicationRecord
  belongs_to :ordering_supply
  belongs_to :user
end
