class Professional < ApplicationRecord
  has_many :prescriptions

  def full_name
    self.first_name << " " << self.last_name
  end
end
