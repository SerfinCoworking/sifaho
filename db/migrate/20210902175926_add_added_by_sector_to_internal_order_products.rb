class AddAddedBySectorToInternalOrderProducts < ActiveRecord::Migration[5.2]
  def up
    add_reference :internal_order_products, :added_by_sector, foreign_key: { to_table: :sectors }

    # Update all added by sector order products depending on the order type
    InternalOrderProduct.find_each do |order_product|
      order_product.added_by_sector = if order_product.order.provision?
                                        order_product.order.provider_sector
                                      else
                                        order_product.order.applicant_sector
                                      end
      order_product.save(validate: false)
    end
  end

  def down
    remove_column :internal_order_products, :added_by_sector
  end
end
