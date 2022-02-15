class Permission < ApplicationRecord
  belongs_to :permission_module, optional: false

  validates_presence_of :name
end
