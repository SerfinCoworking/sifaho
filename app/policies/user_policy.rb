class UserPolicy < ApplicationPolicy

  def index?
    user.has_permission?(:read_users)
  end

  def show?
    user.has_permission?(:read_users)
  end

  def update?
    record == user || update.any? { |role| user.has_role?(role) }
  end

  def change_sector?
    record.sectors.count > 1 && self.update?
  end

  def edit_permissions?
    user.has_permission?(:update_permissions)
  end

  def update_permissions?
    if ( record.has_role? :admin ) && ( record == user )
      return true
    elsif record.has_role? :admin
      return false
    else
      update_permissions.any? { |role| user.has_role?(role) }
    end
  end

  def show_establishment?
    record.has_role?(:admin)
  end

  private

  def index_user
    [ :admin, :gestor_usuarios ]
  end

  def update
    [ :admin, :gestor_usuarios ]
  end

  def update_permissions
    [ :admin, :gestor_usuarios ]
  end
end
