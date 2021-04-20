class PurchaseMovement < ApplicationRecord
  belongs_to :user
  belongs_to :purchase
  belongs_to :sector
end
