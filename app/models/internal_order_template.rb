class InternalOrderTemplate < ApplicationRecord
  belongs_to :owner_sector, class_name: 'Sector'
  belongs_to :detination_sector, class_name: 'Sector'
  belongs_to :created_by, class_name: "User"

  validates_presence_of :name
end
