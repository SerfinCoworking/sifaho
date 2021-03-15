class CreateExternalOrderProductTemplate < ActiveRecord::Migration[5.2]
  def change
    create_table :external_order_product_templates do |t|
      t.references :product, index: true
      t.references :external_order_template, index: {name: :unique_ext_ord_prod_tem_on_ext_ord_tem}

      t.timestamps
    end
  end
end
