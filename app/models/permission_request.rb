class PermissionRequest < ApplicationRecord
  enum status: { nueva: 0, terminada: 1, rechazada: 2 }

  belongs_to :user

  validates_presence_of :user, :establishment, :sector, :role, :observation
end
