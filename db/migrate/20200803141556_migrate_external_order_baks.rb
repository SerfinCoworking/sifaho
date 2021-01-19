class MigrateExternalOrderBaks < ActiveRecord::Migration[5.2]
  def change
    ExternalOrder.find_each do |order|
      ExternalOrderBak.create!(
        id: order.id,
        observation: order.observation,
        date_received: order.date_received,
        created_at: order.created_at,
        updated_at: order.updated_at,
        deleted_at: order.deleted_at,
        applicant_sector_id: order.applicant_sector_id,
        provider_sector_id: order.provider_sector_id,
        requested_date: order.requested_date,
        sent_date: order.sent_date,
        status: order.status,
        audited_by_id: order.audited_by_id,
        accepted_by_id: order.accepted_by_id,
        sent_by_id: order.sent_by_id,
        received_by_id: order.received_by_id,
        accepted_date: order.accepted_date,
        order_type: order.order_type,
        created_by_id: order.created_by_id,
        remit_code: order.remit_code,
        sent_request_by_id: order.sent_request_by_id,
        rejected_by_id: order.rejected_by_id,
      )
    end
  end
end
