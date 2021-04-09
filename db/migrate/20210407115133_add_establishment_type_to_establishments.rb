class AddEstablishmentTypeToEstablishments < ActiveRecord::Migration[5.2]
  def change
    add_reference :establishments, :establishment_type, index: true
  end
end
