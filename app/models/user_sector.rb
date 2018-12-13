class UserSector < ApplicationRecord
  # Relaciones
  belongs_to :user
  belongs_to :sector
  
  # Validaciones
  validates_presence_of :user, :sector
end
