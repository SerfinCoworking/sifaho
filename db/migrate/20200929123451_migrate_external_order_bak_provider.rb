class MigrateExternalOrderBaksToExternalOrders < ActiveRecord::Migration[5.2]
  def change
    ExternalOrderBak.despacho.find_each do |despacho|
      ExternalOrder.create!(
        id: despacho.id,
        observation: despacho.observation,
        date_received: despacho.date_received,
        created_at: despacho.created_at,
        updated_at: despacho.updated_at,
        deleted_at: despacho.deleted_at,
        applicant_sector_id: despacho.applicant_sector_id,
        provider_sector_id: despacho.provider_sector_id,
        requested_date: despacho.requested_date,
        sent_date: despacho.sent_date,
        status: despacho.status,
        audited_by_id: despacho.audited_by_id,
        accepted_by_id: despacho.accepted_by_id,
        sent_by_id: despacho.sent_by_id,
        received_by_id: despacho.received_by_id,
        accepted_date: despacho.accepted_date,
        order_type: 'provision',
        created_by_id: despacho.created_by_id,
        remit_code: despacho.remit_code,
        sent_request_by_id: despacho.sent_request_by_id,
        rejected_by_id: despacho.rejected_by_id,
      )
    end
  end
end
