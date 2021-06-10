class AddStatusToBeds < ActiveRecord::Migration[5.2]
  def change
    add_column :beds, :status, :integer, default: 0
  end
end
