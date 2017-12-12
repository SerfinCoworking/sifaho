class Patient < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dni, presence: true

  belongs_to :patient_type
  has_many :prescriptions

  def full_info
    self.first_name<<" "<<self.last_name<<" "<<self.dni.to_s
  end
end
