class PopulateEstablishmentSectorsCountSecondTime < ActiveRecord::Migration[5.2]
  def up
    Establishment.find_each do |establishment|
      Establishment.reset_counters(establishment.id, :sectors)
    end
  end
end
