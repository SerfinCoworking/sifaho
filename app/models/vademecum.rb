class Vademecum < ApplicationRecord
  # Relaciones
  has_many :medication

  # Validaciones
  validates_presence_of :level_complexity
  validates_presence_of :specialty_enabled
  validates_presence_of :medication_name
  validates_presence_of :indications
end
