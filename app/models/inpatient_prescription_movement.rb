class InpatientPrescriptionMovement < ApplicationRecord
  belongs_to :order, class_name: 'InpatientPrescription'
  belongs_to :order_product, class_name: 'InpatientPrescriptionProduct'
  belongs_to :user
  belongs_to :sector

  validates :action, presence: true
end
