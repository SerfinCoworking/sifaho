class Professional < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dni, presence: true

  has_many :prescriptions

  def full_name
    if self.first_name and self.last_name
      self.first_name << " " << self.last_name
    end
  end
end
