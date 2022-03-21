class ProfessionalPolicy < ApplicationPolicy
  def index?
    user.has_permission?(:read_professionals)
  end

  def show?
    index?
  end

  def create?
    user.has_permission?(:create_professionals)
  end

  def new?
    create?
  end

  def update?
    user.has_permission?(:update_professionals)
  end

  def edit?
    update?
  end

  def destroy?
    user.has_permission?(:destroy_professionals)
  end

  def delete?
    destroy?
  end
end
