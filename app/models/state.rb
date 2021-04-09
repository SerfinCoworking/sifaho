class State < ApplicationRecord
  belongs_to :country
  has_many :cities
  has_many :departments
  
  validates_presence_of :name
end
