class DashboardPolicy < Struct.new(:user, :dashboard)
  def sidebar?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medico, :enfermero)
  end

  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medico, :enfermero)
  end
end