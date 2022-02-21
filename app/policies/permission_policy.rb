class PermissionPolicy < ApplicationPolicy

  def edit?
    @user.has_permission?(:update_permissions)
  end

  def update?
    edit?
  end

end
