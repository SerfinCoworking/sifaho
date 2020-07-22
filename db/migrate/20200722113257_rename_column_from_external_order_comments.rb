class RenameColumnFromExternalOrderComments < ActiveRecord::Migration[5.2]
  def change
    rename_column :external_order_comments, :external_order_id, :order_id
  end
end
