class MigrateOrderingSupplyMovements < ActiveRecord::Migration[5.1]
  def change
    OrderingSupply.find_each do |ord|
      if ord.created_by.present? 
        OrderingSupplyMovement.create(
          user: ord.created_by, 
          ordering_supply: ord, 
          action: 'Creó', 
          created_at: ord.created_at, 
          sector: ord.created_by.sector
        )
      end
      if ord.audited_by.present?
        OrderingSupplyMovement.create(
          user: ord.audited_by,
          ordering_supply: ord,
          action: 'Auditó',
          created_at: ord.updated_at,
          sector: ord.audited_by.sector
        )
      end
      if ord.accepted_by.present?
        OrderingSupplyMovement.create(
          user: ord.accepted_by,
          ordering_supply: ord,
          action: 'Aceptó',
          created_at: ord.accepted_date,
          sector: ord.accepted_by.sector
        )
      end
      if ord.sent_by.present?
        OrderingSupplyMovement.create(
          user: ord.sent_by,
          ordering_supply: ord,
          action: 'Envió',
          created_at: ord.sent_date,
          sector: ord.sent_by.sector
        )
      end
      if ord.received_by.present?
        OrderingSupplyMovement.create(
          user: ord.received_by,
          ordering_supply: ord,
          action: 'Recibió',
          created_at: ord.date_received,
          sector: ord.received_by.sector
        )
      end
    end
  end
end
