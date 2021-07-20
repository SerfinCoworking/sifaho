class RemoveEnrollmentToProfessionals < ActiveRecord::Migration[5.2]
  def change
    remove_column :professionals, :enrollment
  end
end
