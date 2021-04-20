class PurchaseComment < ApplicationRecord
  belongs_to :order, class_name: 'Purchase' 
  belongs_to :user
end
