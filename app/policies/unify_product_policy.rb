class UnifyProductPolicy < ApplicationPolicy

  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin)
  end

  def new?
    create?
  end

  def update?
    return if record.applied?

    user.has_any_role?(:admin)
  end

  def edit?
    update?
  end

  def apply?
    update?
  end

  def confirm_apply?
    update?
  end

  def destroy?
    user.has_any_role?(:admin)
  end

  def delete?
    destroy?
  end

  def restore?
    destroy?
  end
end
