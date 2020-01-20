class RenameOrderingSupplyCommentToExternalOrderComment < ActiveRecord::Migration[5.2]
  def change
    rename_table :ordering_supply_comments, :external_order_comments
  end
end
