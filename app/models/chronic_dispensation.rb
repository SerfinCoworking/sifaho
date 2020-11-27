class ChronicDispensation < ApplicationRecord
  belongs_to :chronic_prescription, inverse_of: 'chronic_dispensations'
  has_many :chronic_prescription_products, inverse_of: 'chronic_dispensation'

  enum status: { pendiente: 0, dispensada: 1}

  validates :chronic_prescription_products, :presence => {:message => "Debe agregar almenos 1 insumo"}
  validates_associated :chronic_prescription_products
  
  accepts_nested_attributes_for :chronic_prescription_products,
  :allow_destroy => true
end