class PrescriptionMedication < ApplicationRecord
  belongs_to :prescription
  belongs_to :medication

  accepts_nested_attributes_for :medication,
                                :reject_if => :all_blank
end
