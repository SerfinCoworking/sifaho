class Patient < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dni, presence: true

  belongs_to :patient_type
end
