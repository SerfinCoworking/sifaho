class ExternalOrderComment < ApplicationRecord
  belongs_to :order, class_name: 'ExternalOrder' 
  belongs_to :user
end
