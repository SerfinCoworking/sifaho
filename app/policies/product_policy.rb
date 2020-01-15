class ProductPolicy < ApplicationPolicy

  def index?
    user.has_any_role?(:admin)
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
    user.has_any_role?(:admin)
  end

  def edit?
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

  def trash_index?
    user.has_any_role?(:admin)
  end
end
