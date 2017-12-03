class AddNameToVademecum < ActiveRecord::Migration[5.1]
  def change
    add_column :vademecums, :name, :string
  end
end
