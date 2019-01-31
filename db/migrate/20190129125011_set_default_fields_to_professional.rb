class SetDefaultFieldsToProfessional < ActiveRecord::Migration[5.1]
  def change
    change_column :professionals, :professional_type_id, :bigint, default: 5
    change_column :professionals, :is_active, :boolean, default: true
  end
end
