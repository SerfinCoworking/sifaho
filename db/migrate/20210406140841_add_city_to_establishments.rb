class AddCityToEstablishments < ActiveRecord::Migration[5.2]
  def change
    add_reference :establishments, :city, index: true
  end
end
