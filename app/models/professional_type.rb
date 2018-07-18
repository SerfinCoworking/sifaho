class ProfessionalType < ApplicationRecord
  has_many :professionals

  validates_presence_of :name
end
