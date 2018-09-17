class RemoveDeprecatedReferencesFromInternalOrder < ActiveRecord::Migration[5.1]
  def change
    remove_reference :internal_orders, :provider, index: true
    remove_reference :internal_orders, :applicant, index: true
    remove_reference :internal_orders, :sector, foreign_key: true
  end
end
