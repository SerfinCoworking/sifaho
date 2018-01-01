class AddSectorToProfessional < ActiveRecord::Migration[5.1]
  def change
    add_reference :professionals, :sector, foreign_key: true
  end
end
