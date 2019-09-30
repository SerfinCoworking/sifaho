class PatientPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :enfermero, :abm_paciente)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin, :abm_paciente, :farmaceutico, :auxiliar_farmacia)
  end

  def new?
    create?
  end

  def update?
    user.has_any_role?(:admin, :abm_paciente)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_any_role?(:admin)
  end
end
