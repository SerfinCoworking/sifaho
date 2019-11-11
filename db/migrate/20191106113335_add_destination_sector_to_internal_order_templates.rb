class AddDestinationSectorToInternalOrderTemplates < ActiveRecord::Migration[5.2]
  def change
    add_reference :internal_order_templates, :destination_sector, index: true
    remove_column :internal_order_templates, :detination_sector_id 
  end
end
