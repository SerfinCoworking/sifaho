class ReceiptMovement < ApplicationRecord
  # Relationships
  belongs_to :user
  belongs_to :receipt
  belongs_to :sector
end
