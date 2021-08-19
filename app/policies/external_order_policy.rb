class ExternalOrderPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
  end

  def new_report?
    new_report.any? { |role| user.has_role?(role) }
  end

  def generate_report?
    new_report?
  end

end
