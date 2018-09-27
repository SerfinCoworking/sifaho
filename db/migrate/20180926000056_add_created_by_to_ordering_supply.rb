class AddCreatedByToOrderingSupply < ActiveRecord::Migration[5.1]
  def change
    add_reference :ordering_supplies, :created_by, index: true
  end
end
