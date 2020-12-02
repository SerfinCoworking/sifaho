class ChronicPrescriptionComment < ApplicationRecord

  belongs_to :order, class_name: 'ChronicPrescription'
  belongs_to :user

end
