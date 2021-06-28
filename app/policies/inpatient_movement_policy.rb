class InpatientMovementPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :enfermero)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def new?
    create?
  end

  def update?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def edit?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def destroy?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def delete?
    destroy?
  end
end
