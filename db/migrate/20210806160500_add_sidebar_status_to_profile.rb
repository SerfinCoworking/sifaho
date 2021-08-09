class AddSidebarStatusToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :sidebar_status, :integer, default: 0
  end
end
