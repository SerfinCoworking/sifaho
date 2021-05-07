class AddProvenanceToReceiptProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :receipt_products, :provenance, index: true, default: 1
  end
end
