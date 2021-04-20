class InternalOrderComment < ApplicationRecord
  belongs_to :order, class_name: 'InternalOrder'
  belongs_to :user
end
