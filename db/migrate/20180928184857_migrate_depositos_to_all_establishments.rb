class MigrateDepositosToAllEstablishments < ActiveRecord::Migration[5.1]
  Establishment.find_each do |est|
    unless est.sectors.exists?
      Sector.create(name:"Depósito", description: est.name, complexity_level: 3, establishment_id: est.id)
    end
  end
end
