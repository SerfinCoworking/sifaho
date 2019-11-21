class CreateOrderingSupplyTemplateSupplies < ActiveRecord::Migration[5.2]
  def change
    create_table :ordering_supply_template_supplies do |t|
      t.references :ordering_supply_template, index: { name: "o_s_template" }
      t.references :supply, index: true

      t.timestamps  
    end
    add_column :ordering_supply_template_supplies, :rank, :integer, default: 0
  end
end
