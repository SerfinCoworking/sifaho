class Department < ApplicationRecord

  # Relationships
  belongs_to :sanitary_zone, optional: true
  belongs_to :state
  has_many :cities
  has_many :establishments, through: :cities
end
