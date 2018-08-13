class RemoveResponsableFromInternalOrder < ActiveRecord::Migration[5.1]
  def change
    remove_column :internal_orders, :responsable_id
    remove_column :internal_orders, :sector_id
  end
end
