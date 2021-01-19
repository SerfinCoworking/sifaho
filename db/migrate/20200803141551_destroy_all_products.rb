class DestroyAllProducts < ActiveRecord::Migration[5.2]
  def change
    Product.find_each do |product|
      product.destroy!
    end
  end
end
