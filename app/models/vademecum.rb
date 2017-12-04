class Vademecum < ApplicationRecord
  validates :name, presence: true
  validates :complexity_level, presence: true
  validates :description, presence: true

  has_many :medication
end
