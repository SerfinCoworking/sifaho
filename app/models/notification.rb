# Auto generate with notifications gem.
class Notification < ActiveRecord::Base
  include Notifications::Model

  belongs_to :actor_sector, class_name: 'Sector'
  # Write your custom methods...
end
