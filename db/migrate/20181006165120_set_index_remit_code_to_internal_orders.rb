class SetIndexRemitCodeToInternalOrders < ActiveRecord::Migration[5.1]
  @count = 0 
  InternalOrder.find_each do |io|
    if io.provision?
      io.remit_code = io.provider_sector.name[0..3].upcase+'prov'+@count.to_s;
    else
      io.remit_code = io.applicant_sector.name[0..3].upcase+'sol'+@count.to_s;
    end
    @count += 1
    io.save!
  end
  def change
    add_index :internal_orders, :remit_code, unique: true
  end
end
