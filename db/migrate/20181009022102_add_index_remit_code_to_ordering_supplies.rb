class AddIndexRemitCodeToOrderingSupplies < ActiveRecord::Migration[5.1]
  @count = 0 
  OrderingSupply.find_each do |os|
    if os.despacho?
      os.remit_code = os.provider_sector.name[0..3].upcase+'des'+@count.to_s;
    else
      os.remit_code = os.applicant_sector.name[0..3].upcase+'rec'+@count.to_s;
    end
    @count += 1
    os.save!
  end
  def change
    add_index :ordering_supplies, :remit_code, unique: true
  end
end
