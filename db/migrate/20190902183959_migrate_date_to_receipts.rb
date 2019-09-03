class MigrateDateToReceipts < ActiveRecord::Migration[5.2]
  def change
    OrderingSupply.find_each do |ord|
      if ord.recibo?
        if ord.date_received.present?
          ord.sent_date = ord.date_received
          ord.save!
        end
      end
    end
  end
end
