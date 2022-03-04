class DashboardPolicy < Struct.new(:user, :dashboard)
  def sidebar?
    # ROLES ARE DEPRECATED
    user.roles.any? || user.permissions.any?
  end

  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medico, :enfermero)
  end
end