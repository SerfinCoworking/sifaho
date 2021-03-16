class InternalOrderProductTemplate < ApplicationRecord
  default_scope { joins(:product).order("products.name") }

  belongs_to :internal_order_template
  belongs_to :product
  validate :uniqueness_product_in_the_order

  delegate :name, :code, to: :product, prefix: :product
  delegate :unity, to: :product

  # Validacion: evitar duplicidad de productos en una misma plantilla
  def uniqueness_product_in_the_order
    (self.internal_order_template.internal_order_product_templates.uniq - [self]).each do |eop|
      if eop.product_id == self.product_id
        errors.add(:uniqueness_product_in_the_order, "El producto código ya se encuentra en la orden")      
      end
    end
  end
end
