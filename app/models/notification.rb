# Auto generate with notifications gem.
class Notification < ActiveRecord::Base
  include Notifications::Model

  belongs_to :actor_sector, class_name: 'Sector'
  # Write your custom methods...

  def self.destroy_with_target_id(id)
    where(target_id: id).each do |notification|
      notification.destroy
    end
  end
end
