class AddVademecumToMedication < ActiveRecord::Migration[5.1]
  def change
    add_reference :medications, :vademecum
  end
end
