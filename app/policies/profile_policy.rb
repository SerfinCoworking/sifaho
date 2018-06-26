class ProfilePolicy < ApplicationPolicy

  def update?
    user.present? && ((record.user == user) || (user.has_role? :admin))
  end
end
