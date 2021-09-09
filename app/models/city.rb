class City < ApplicationRecord

  # Relationships
  belongs_to :state
  belongs_to :department, optional: true
  has_many :establishments

  # Validations
  validates_presence_of :name
end
