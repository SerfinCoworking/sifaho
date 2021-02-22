class AddReturnedByToLotArchives < ActiveRecord::Migration[5.2]
  def change
    add_reference :lot_archives, :returned_by, index: true
  end
end
