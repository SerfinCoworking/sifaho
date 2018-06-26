class Profile < ApplicationRecord
  enum sex: { hombre: 0, mujer: 1 }

  #Relaciones
  belongs_to :user

  def full_name
    if self.first_name and self.last_name
      self.first_name << " " << self.last_name
    else
      self.first_name
    end
  end
end
