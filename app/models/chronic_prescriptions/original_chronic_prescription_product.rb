class OriginalChronicPrescriptionProduct < ApplicationRecord
  enum treatment_status: { pendiente: 0, terminado: 1, terminado_manual: 2 }

  # Relaciones
  belongs_to :chronic_prescription, inverse_of: 'original_chronic_prescription_products'
  belongs_to :finished_by_professional, optional: true, class_name: 'Professional'
  has_many :chronic_prescription_products, inverse_of: 'original_chronic_prescription_product'
  belongs_to :product
  has_many :dispensation_types

  # Validaciones
  validates :request_quantity, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates_presence_of :product_id
  validate :uniqueness_original_product_in_the_order
  validates :finished_by_professional_id, presence: true, if: :terminado_manual?
  validates :finished_observation, presence: true, if: :terminado_manual?
  
  accepts_nested_attributes_for :product,
    :allow_destroy => true

  # Delegaciones
  delegate :unity_name, :name, :code, to: :product, prefix: :product

  scope :excluding_ids, lambda { |ids|
    where(['id NOT IN (?)', ids]) if ids.any?
  }

  scope :for_treatment_statuses, ->(values) do
    return all if values.blank?

    where(treatment_status: treatment_statuses.values_at(*Array(values)))
  end
  
  # Validacion: evitar duplicidad de productos en una misma orden
  def uniqueness_original_product_in_the_order
    (self.chronic_prescription.original_chronic_prescription_products.uniq - [self]).each do |iop| 
      if iop.product_id == self.product_id
        errors.add(:uniqueness_original_product_in_the_order, "Este producto ya se encuentra en la orden")
      end
    end
  end

  # Increment a certain quantity to attribute total_delivered_quantity
  def deliver(a_quantity)
    if self.pendiente?
      self.total_delivered_quantity += a_quantity
      self.total_delivered_quantity < self.total_request_quantity ? pendiente! : terminado!
    else
      errors.add(:base, "El tratamiento de #{self.product.name} ya se ha terminado.")
    end
  end
end
