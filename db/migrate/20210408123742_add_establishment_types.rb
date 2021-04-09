class AddEstablishmentTypes < ActiveRecord::Migration[5.2]
  def change
    EstablishmentType.create(name: 'Zona sanitaria')
    EstablishmentType.create(name: 'Depósito zonal')
    EstablishmentType.create(name: 'Hospital')
    EstablishmentType.create(name: 'Centro de salud')
    EstablishmentType.create(name: 'Centro de salud de día')
    EstablishmentType.create(name: 'Posta sanitaria')
  end
end
