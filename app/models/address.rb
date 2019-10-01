class Address < ApplicationRecord
  belongs_to :country, optional: true
  belongs_to :state, optional: true
  belongs_to :city, optional: true
  has_many :patients

  def country_name
    self.country.present? ? self.country.name.humanize : "----"
  end

  def state_name
    self.state.present? ? self.state.name.humanize : "----"
  end

  def city_name
    self.city.present? ? self.city.name.humanize : "----"
  end
end
