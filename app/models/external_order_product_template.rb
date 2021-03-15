class ExternalOrderProductTemplate < ApplicationRecord
  belongs_to :external_order_template
  belongs_to :product

  delegate :name, to: :product, prefix: :product
  delegate :unity, to: :product
end
