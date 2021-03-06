class CreateProfessionals < ActiveRecord::Migration[5.1]
  def change
    create_table :professionals do |t|
      t.string :first_name, :limit => 50
      t.string :last_name, :limit => 50
      t.string :fullname, :limit => 102
      t.integer :dni
      t.string :enrollment, :limit => 20
      t.string :email
      t.string :phone
      t.column :sex, :integer, default: 1
      t.boolean :is_active, default: true
      t.string :docket, :limit => 10
      t.references :user, index: true

      t.timestamps
    end
    add_reference :professionals, :professional_type, index: true, default: 5
  end
end