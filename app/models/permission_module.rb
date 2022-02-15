class PermissionModule < ApplicationRecord
  has_many :permissions

  validates_presence_of :name
end
