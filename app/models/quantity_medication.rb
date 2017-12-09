class QuantityMedication < ApplicationRecord
  belongs_to :medication
  belongs_to :quantifiable, :polymorphic => true
end
