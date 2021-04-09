class AddCuieToEstablishments < ActiveRecord::Migration[5.2]
  def change
    add_column :establishments, :cuie, :string
  end
end
