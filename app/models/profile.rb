class Profile < ApplicationRecord
  enum sex: { indeterminado: 1, femenino: 2, masculino: 3 }

  #Relaciones
  belongs_to :user
  has_one_attached :avatar

  def full_name
    self.last_name+" "+self.first_name
  end
end
