class Bed < ApplicationRecord
  enum status: { disponible: 0, ocupada: 1 } 

  belongs_to :bedroom
  belongs_to :service, class_name: 'Sector'
  has_one :establishment, :through => :service
  has_many :bed_orders

  validates :name, presence: true, uniqueness: true
  validates_presence_of :service

  scope :establishment, -> (establishment_id) {joins(:establishment).where("establishments.id=?", establishment_id)}
end
