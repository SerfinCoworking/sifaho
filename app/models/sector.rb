class Sector < ApplicationRecord
  validates :sector_name, presence: true
  validates :complexity_level, presence: true

  has_many :professionals
  has_many :users

  def self.options_for_select
    order('LOWER(sector_name)').map { |e| [e.sector_name, e.id] }
  end
end
