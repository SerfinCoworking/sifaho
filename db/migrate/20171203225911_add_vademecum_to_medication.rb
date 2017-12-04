class AddVademecumToMedication < ActiveRecord::Migration[5.1]
  def change
    add_reference :medications, :vademecum, foreign_key: true
  end
end
