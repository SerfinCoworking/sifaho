class AddStampsmpsToOrderingSupplies < ActiveRecord::Migration[5.1]
  def change
    add_reference :ordering_supplies, :audited_by, index: true
    add_reference :ordering_supplies, :accepted_by, index: true
    add_reference :ordering_supplies, :sent_by, index: true
    add_reference :ordering_supplies, :received_by, index: true
    add_column :ordering_supplies, :accepted_date, :datetime

    remove_reference :ordering_supplies, :responsable, index: true
    remove_reference :ordering_supplies, :sector, index: true
  end
end
