class PopulateUsersCount < ActiveRecord::Migration[5.2]
  def change
    Establishment.find_each do |establishment|
      Establishment.reset_counters(establishment.id, :users)
    end
  end
end
