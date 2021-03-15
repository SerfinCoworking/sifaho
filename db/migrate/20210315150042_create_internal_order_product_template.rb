class CreateInternalOrderProductTemplate < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_order_product_templates do |t|
      t.references :product, index: true
      t.references :internal_order_template, index: {name: :unique_int_ord_prod_tem_on_int_ord_tem}

      t.timestamps
    end
  end
end
