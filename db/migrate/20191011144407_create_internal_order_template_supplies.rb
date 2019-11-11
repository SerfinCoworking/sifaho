class CreateInternalOrderTemplateSupplies < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_order_template_supplies do |t|
      t.references :internal_order_template, index: { name: "i_o_template" }
      t.references :supply, index: { name: "supply_id" }

      t.timestamps  
    end
    add_column :internal_order_template_supplies, :rank, :integer, default: 0
  end
end
