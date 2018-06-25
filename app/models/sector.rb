class Sector < ApplicationRecord
  # Relaciones
  has_many :professionals
  has_many :users

  # Validaciones
  validates_presence_of :sector_name
  validates_presence_of :complexity_level

  def self.options_for_select
    order('LOWER(sector_name)').map { |e| [e.sector_name, e.id] }
  end
end
