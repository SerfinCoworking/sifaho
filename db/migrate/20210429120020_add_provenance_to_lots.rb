class AddProvenanceToLots < ActiveRecord::Migration[5.2]
  def change
    add_reference :lots, :provenance, index: true, default: 1
  end
end
