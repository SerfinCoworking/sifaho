class BedOrderMovement < ApplicationRecord
  belongs_to :user
  belongs_to :bed_order
  belongs_to :sector
end
