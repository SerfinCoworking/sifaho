class PermissionUser < ApplicationRecord
  belongs_to :user
  belongs_to :sector
  belongs_to :permission
end
