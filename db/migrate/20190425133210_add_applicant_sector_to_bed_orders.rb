class AddApplicantSectorToBedOrders < ActiveRecord::Migration[5.2]
  def change
    add_reference :bed_orders, :applicant_sector, index: true
  end
end
