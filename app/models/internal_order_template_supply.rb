class InternalOrderTemplateSupply < ApplicationRecord
  belongs_to :internal_order_template
  belongs_to :supply

  delegate :name, to: :supply, prefix: :supply
  delegate :unity, to: :supply
end
