class Sector < ApplicationRecord
  validates_presence_of :sector_name, presence: true
  validates_presence_of :complexity_level, presence: true  

  has_many :professionals

  def self.options_for_select
    order('LOWER(sector_name)').map { |e| [e.sector_name, e.id] }
  end
end
