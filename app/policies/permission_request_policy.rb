class PermissionRequestPolicy < ApplicationPolicy

  def index?
    user.has_any_role?(:admin, :gestor_usuarios)
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    user.has_any_role?(:admin)
  end

  def end?
    if record.nueva?
      update?
    end
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
