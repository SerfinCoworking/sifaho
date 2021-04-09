class AddSanitaryZoneToEstablishments < ActiveRecord::Migration[5.2]
  def change
    add_reference :establishments, :sanitary_zone, index: true
  end
end
