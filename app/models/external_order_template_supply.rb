class ExternalOrderTemplateSupply < ApplicationRecord
  belongs_to :external_order_template
  belongs_to :supply

  delegate :name, to: :supply, prefix: :supply
  delegate :unity, to: :supply
end
