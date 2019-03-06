class UserPolicy < ApplicationPolicy

  def index?
    index_user.any? { |role| user.has_role?(role) }
  end

  def update?
    record == user || update.any? { |role| user.has_role?(role) }
  end

  def change_sector?
    record.sectors.count > 1 && self.update? 
  end

  def edit_permissions?
    self.update? 
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

  def edit_permissions?
    self.update_permissions?
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
