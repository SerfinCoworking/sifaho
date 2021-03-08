class OriginalChronicPrescriptionProduct < ApplicationRecord

  # Relaciones
  belongs_to :chronic_prescription, inverse_of: 'original_chronic_prescription_products'
  has_many :chronic_prescription_products, inverse_of: 'original_chronic_prescription_product'
  belongs_to :product
  has_many :dispensation_types

  # Validaciones
  validates :request_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates_presence_of :product_id
  validate :uniqueness_original_product_in_the_order
  
  accepts_nested_attributes_for :product,
    :allow_destroy => true

  # Delegaciones
  delegate :unity_name, :name, :code, to: :product, prefix: :product

  scope :excluding_ids, lambda { |ids|
    where(['id NOT IN (?)', ids]) if ids.any?
  }
  
   # Validacion: evitar duplicidad de productos en una misma orden
  def uniqueness_original_product_in_the_order
    (self.chronic_prescription.original_chronic_prescription_products.uniq - [self]).each do |iop| 
      if iop.product_id == self.product_id
        errors.add(:uniqueness_original_product_in_the_order, "Este producto ya se encuentra en la orden")      
      end
    end
  end
end
