class AddAttributesToAddress < ActiveRecord::Migration[5.2]
  def change
    add_reference :addresses, :country, foreign_key: true
    add_reference :addresses, :state, foreign_key: true
  end
end
