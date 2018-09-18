class AddProviderAndApplicantSectorsToInternalOrder < ActiveRecord::Migration[5.1]
  def change
    add_reference :internal_orders, :provider_sector, index: true
    add_reference :internal_orders, :applicant_sector, index: true
  end
end
