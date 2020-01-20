class ChangeColumnsNames < ActiveRecord::Migration[5.2]
  def change
    rename_column :external_order_movements, :ordering_supply_id, :external_order_id
    rename_column :external_order_comments, :ordering_supply_id, :external_order_id
  end
end
