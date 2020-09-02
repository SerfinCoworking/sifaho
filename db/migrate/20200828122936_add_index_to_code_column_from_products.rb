class AddIndexToCodeColumnFromProducts < ActiveRecord::Migration[5.2]
  def change
    add_index :products, :code, unique: true
  end
  
end
