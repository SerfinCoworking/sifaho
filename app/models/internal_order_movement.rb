class InternalOrderMovement < ApplicationRecord
  belongs_to :user
  belongs_to :internal_order
  belongs_to :sector
end
