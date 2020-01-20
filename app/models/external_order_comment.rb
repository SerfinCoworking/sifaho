class ExternalOrderComment < ApplicationRecord
  belongs_to :external_order
  belongs_to :user
end
