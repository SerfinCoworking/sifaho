class AddServiceToBed < ActiveRecord::Migration[5.2]
  def change
    add_reference :beds, :service, index: true
  end
end
