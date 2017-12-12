class QuantityMedication < ApplicationRecord
  validates :quantity, presence: true
  validates :medication, presence: true

  belongs_to :medication
  belongs_to :quantifiable, :polymorphic => true


  accepts_nested_attributes_for :medication
end
