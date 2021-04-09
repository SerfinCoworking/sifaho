class AddDepartmentToCities < ActiveRecord::Migration[5.2]
  def change
    add_reference :cities, :department, index: true
  end
end
