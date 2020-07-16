class NotificationPolicy < ApplicationPolicy
  def index?
    user.roles.any?
  end
end
