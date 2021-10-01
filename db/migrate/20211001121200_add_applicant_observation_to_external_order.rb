class AddApplicantObservationToExternalOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :external_orders, :applicant_observation, :text
  end
end
