class Country < ApplicationRecord
  
  # Relationships
  has_many :states

  # Validations
  validates_presence_of :name
end
