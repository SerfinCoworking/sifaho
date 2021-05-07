class AddLotsCountToLotProvenances < ActiveRecord::Migration[5.2]
  def change
    add_column :lot_provenances, :lots_count, :integer, default: 0
  end
end
