class RemoveUserReferenceFromSector < ActiveRecord::Migration[5.1]
  def change
    remove_reference :sectors, :user, foreign_key: true
  end
end
