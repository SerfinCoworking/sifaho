class AddActorSectorToNotifications < ActiveRecord::Migration[5.1]
  def change
    add_reference :notifications, :actor_sector, index: true
  end
end
