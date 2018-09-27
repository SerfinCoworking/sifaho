class RenameStatusOrderingSupply < ActiveRecord::Migration[5.1]
  def change
    rename_column :ordering_supplies, :provider_status, :status 
    remove_column :ordering_supplies, :applicant_status
  end
end
