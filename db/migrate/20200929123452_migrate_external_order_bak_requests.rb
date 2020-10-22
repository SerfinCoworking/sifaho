class MigrateExternalOrderBakRequests < ActiveRecord::Migration[5.2]
  def change
    ExternalOrderBak.solicitud_abastecimiento.find_each do |solicitud|
      ExternalOrder.create!(
        id: solicitud.id,
        observation: solicitud.observation,
        date_received: solicitud.date_received,
        created_at: solicitud.created_at,
        updated_at: solicitud.updated_at,
        deleted_at: solicitud.deleted_at,
        applicant_sector_id: solicitud.applicant_sector_id,
        provider_sector_id: solicitud.provider_sector_id,
        requested_date: solicitud.requested_date,
        sent_date: solicitud.sent_date,
        status: solicitud.status,
        audited_by_id: solicitud.audited_by_id,
        accepted_by_id: solicitud.accepted_by_id,
        sent_by_id: solicitud.sent_by_id,
        received_by_id: solicitud.received_by_id,
        accepted_date: solicitud.accepted_date,
        order_type: 'solicitud',
        created_by_id: solicitud.created_by_id,
        remit_code: solicitud.remit_code,
        sent_request_by_id: solicitud.sent_request_by_id,
        rejected_by_id: solicitud.rejected_by_id,
      )
    end
  end
end
