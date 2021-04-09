class City < ApplicationRecord
  belongs_to :state
  belongs_to :department, optional: true
  has_many :establishments

  validates_presence_of :name
end
