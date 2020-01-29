class AddProductToStocks < ActiveRecord::Migration[5.2]
  def change
    add_reference :stocks, :product, foreign_key: true
  end
end
