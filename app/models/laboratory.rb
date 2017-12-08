class Laboratory < ApplicationRecord
  validates :name, presence: true

  has_many :medication_brand
end
