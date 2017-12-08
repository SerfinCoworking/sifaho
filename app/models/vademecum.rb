class Vademecum < ApplicationRecord
  validates :level_complexity, presence: true
  validates :specialty_enabled, presence: true
  validates :medication_name, presence: true
  validates :indications, presence: true

  has_many :medication
end
