class RenameObservationColumnToApplicantObservation < ActiveRecord::Migration[5.2]
  def up
    rename_column :external_order_templates, :observation, :applicant_observation
  end

  def down
    rename_column :external_order_templates, :applicant_observation, :observation
  end
end
