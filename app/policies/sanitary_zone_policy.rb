class SanitaryZonePolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin)
  end

  def show?
    index?
  end

  def new?
    user.has_any_role?(:admin)
  end

  def edit?
    user.has_any_role?(:admin)
  end


  def destroy?
    user.has_any_role?(:admin)
  end

  def delete?
    destroy?
  end
end
