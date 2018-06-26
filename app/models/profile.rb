class Profile < ApplicationRecord
  enum gender: { masculino: 0, femenino: 1 }

  #Relaciones
  belongs_to :user
end
