class AddSentDateAndStatusesToOrderingSupply < ActiveRecord::Migration[5.1]
  def change
    add_column :ordering_supplies, :sent_date, :datetime
    add_column :ordering_supplies, :applicant_status, :integer, default: 0
    add_column :ordering_supplies, :provider_status, :integer, default: 0
    remove_column :ordering_supplies, :status
  end
end
