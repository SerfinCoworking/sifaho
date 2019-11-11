class AddObservationToInternalOrderTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :internal_order_templates, :observation, :text
  end
end
