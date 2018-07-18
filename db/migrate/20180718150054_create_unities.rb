class CreateUnities < ActiveRecord::Migration[5.1]
  def change
    create_table :unities do |t|
      t.string :name, :limit => 100
      t.integer :simela_group
      t.decimal :simela_relation, precision: 10, scale: 4
    end
  end
end
