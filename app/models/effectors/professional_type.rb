class ProfessionalType < ApplicationRecord
  has_many :professionals

  validates_presence_of :name

  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end
end
