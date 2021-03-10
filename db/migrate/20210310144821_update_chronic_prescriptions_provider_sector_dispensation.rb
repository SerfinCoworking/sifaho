class UpdateChronicPrescriptionsProviderSectorDispensation < ActiveRecord::Migration[5.2]
  def up
    # Se actualiza el campo provider_sector de cada dispensacion
    ChronicDispensation.find_each do |cd|
      puts "Chronic Dispensation #{cd.id}".colorize(background: :blue)
      begin
        cd.provider_sector_id = cd.lot_stocks.first.stock.sector_id
        cd.save!(validate: false)
      rescue
        cd.provider_sector_id = cd.chronic_prescription.provider_sector_id
        cd.save!(validate: false)
      end

    end

    puts "Se actualizaron #{ChronicDispensation.all.count} dispensaciones cronicas".colorize(background: :green)
  end

  def down

  end
end
