class MigrateActorSectorsToNotifications < ActiveRecord::Migration[5.1]
  def change
    Notification.find_each do |noti|
      noti.actor_sector = noti.actor.sector
      noti.save!
    end
  end 
end
