class Bedroom < ApplicationRecord
  # Relations
  belongs_to :location_sector, class_name: 'Sector'
  has_one :establishment, :through => :location_sector
  has_many :beds

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :location_sector, presence: true

  scope :establishment, -> (establishment_id) {joins(:establishment).where("establishments.id=?", establishment_id)}
end
