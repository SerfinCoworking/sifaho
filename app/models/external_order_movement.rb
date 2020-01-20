class ExternalOrderMovement < ApplicationRecord
  belongs_to :user
  belongs_to :external_order
  belongs_to :sector
end
