class CreateProfessionalTypes < ActiveRecord::Migration[5.1]
  def change
    create_table :professional_types do |t|
      t.string :name, :limit => 50
    end
  end
end
