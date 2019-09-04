class PopulateEstablishmentSectorsCount < ActiveRecord::Migration[5.2]
  def change
    Establishment.find_each do |establishment|
      Establishment.reset_counters(establishment.id, :sectors)
    end
  end
end
