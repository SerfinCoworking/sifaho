class Bedroom < ApplicationRecord
  belongs_to :sector
  has_one :establishment, :through => :sector
  has_many :beds

  validates :name, presence: true, uniqueness: true

  scope :establishment, -> (establishment_id) {joins(:establishment).where("establishments.id=?", establishment_id)}
end
