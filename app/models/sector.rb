class Sector < ApplicationRecord
  has_many :professionals

  def self.options_for_select
    order('LOWER(sector_name)').map { |e| [e.sector_name, e.id] }
  end
end
