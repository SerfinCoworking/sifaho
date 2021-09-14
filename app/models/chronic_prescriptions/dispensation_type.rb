class DispensationType < ApplicationRecord

  # Relationships
  belongs_to :chronic_dispensation
  belongs_to :original_chronic_prescription_product
  has_many :chronic_prescription_products

  # Validations
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :chronic_prescription_products, presence: { message: 'Debe agregar almenos 1 insumo' }
  validates_associated :chronic_prescription_products

  accepts_nested_attributes_for :chronic_prescription_products, reject_if: :chronic_prescription_product_rejectable?

  def chronic_prescription_product_rejectable?(att)
    !att["product_id"].present?
  end
end
