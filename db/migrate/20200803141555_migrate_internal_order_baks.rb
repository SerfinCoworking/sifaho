class MigrateInternalOrderBaks < ActiveRecord::Migration[5.2]
  def change
    InternalOrder.find_each do |order|
      InternalOrderBak.create!(
        id: order.id,
        date_received: order.date_received,
        observation: order.observation,
        provider_status: order.provider_status,
        created_at: order.created_at,
        updated_at: order.updated_at,
        requested_date: order.requested_date,
        sent_date: order.sent_date,
        provider_sector_id: order.provider_sector_id,
        applicant_sector_id: order.applicant_sector_id,
        applicant_status: order.applicant_status,
        audited_by_id: order.audited_by_id,
        sent_by_id: order.sent_by_id,
        received_by_id: order.received_by_id,
        created_by_id: order.created_by_id,
        remit_code: order.remit_code,
        order_type: order.order_type,
        status: order.status,
        sent_request_by_id: order.sent_request_by_id,
        rejected_by_id: order.rejected_by_id,
      )
    end
  end
end