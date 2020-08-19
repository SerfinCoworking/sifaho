class ChangesUnityIdFromProducts < ActiveRecord::Migration[5.2]
  def change
    rename_column :products, :unity_id, :unity
    change_column :products, :unity, :string
  end

end
