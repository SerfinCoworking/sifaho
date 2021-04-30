class PopulateLotProvenanceLotsCount < ActiveRecord::Migration[5.2]
  def up
    LotProvenance.find_each do |lot_provenance|
      LotProvenance.reset_counters(lot_provenance.id, :lots)
    end
  end
end
