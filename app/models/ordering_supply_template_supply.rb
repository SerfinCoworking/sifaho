class OrderingSupplyTemplateSupply < ApplicationRecord
  belongs_to :ordering_supply_template
  belongs_to :supply

  delegate :name, to: :supply, prefix: :supply
  delegate :unity, to: :supply
end
