class AddSectorsToOrderingSupply < ActiveRecord::Migration[5.1]
  def change
    add_reference :ordering_supplies, :applicant_sector, index: true
    add_reference :ordering_supplies, :provider_sector, index: true
  end
end
