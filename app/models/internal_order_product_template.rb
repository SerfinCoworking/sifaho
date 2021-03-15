class InternalOrderProductTemplate < ApplicationRecord
  belongs_to :internal_order_template
  belongs_to :product

  delegate :name, to: :product, prefix: :product
  delegate :unity, to: :product
end
