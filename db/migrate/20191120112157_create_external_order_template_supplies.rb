class CreateExternalOrderTemplateSupplies < ActiveRecord::Migration[5.2]
  def change
    create_table :external_order_template_supplies do |t|
      t.references :external_order_template, index: { name: "o_s_template" }
      t.references :supply, index: true

      t.timestamps  
    end
    add_column :external_order_template_supplies, :rank, :integer, default: 0
  end
end
