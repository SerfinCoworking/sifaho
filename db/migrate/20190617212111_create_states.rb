class CreateStates < ActiveRecord::Migration[5.2]
  def change
    create_table :states do |t|
      t.references :country, foreign_key: true
      t.string :name
    end
  end
end
