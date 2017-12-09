class Supply < ApplicationRecord
  has_many :quantity_supplies
  has_many :prescriptions,
           :through => :quantity_supplies,
           :source => :quantifiable,
           :source_type => 'Prescription'
end
