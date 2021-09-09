class ExternalOrderComment < ApplicationRecord
  # Relationships
  belongs_to :order, class_name: 'ExternalOrder'
  belongs_to :user
end
