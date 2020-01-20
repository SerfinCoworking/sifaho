class MigrateTargetTypeNotifications < ActiveRecord::Migration[5.2]
  def change
    Notification.find_each do |notification|
      if notification.target_type == "OrderingSupply"
        notification.target_type = "ExternalOrder"
      end
      notification.save(validate: false)
    end
  end
end
