class MigrateInternalOrderMovements < ActiveRecord::Migration[5.1]
  def change
    InternalOrder.find_each do |ord|
      if ord.created_by.present? 
        InternalOrderMovement.create(
          user: ord.created_by, 
          internal_order: ord, 
          action: 'Creó', 
          created_at: ord.created_at, 
          sector: ord.created_by.sector
        )
      end
      if ord.audited_by.present?
        InternalOrderMovement.create(
          user: ord.audited_by,
          internal_order: ord,
          action: 'Auditó',
          created_at: ord.updated_at,
          sector: ord.audited_by.sector
        )
      end
      if ord.sent_request_by.present?
        InternalOrderMovement.create(
          user: ord.sent_request_by,
          internal_order: ord,
          action: 'Envió solicitud',
          created_at: ord.requested_date,
          sector: ord.sent_request_by.sector
        )
      end
      if ord.sent_by.present?
        InternalOrderMovement.create(
          user: ord.sent_by,
          internal_order: ord,
          action: 'Envió',
          created_at: ord.sent_date,
          sector: ord.sent_by.sector
        )
      end
      if ord.received_by.present?
        InternalOrderMovement.create(
          user: ord.received_by,
          internal_order: ord,
          action: 'Recibió',
          created_at: ord.date_received,
          sector: ord.received_by.sector
        )
      end
    end
  end
end
