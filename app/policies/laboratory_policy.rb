class LaboratoryPolicy < ApplicationPolicy
  def index?
    show_lab.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def create?
    create_lab.any? { |role| user.has_role?(role) }
  end

  def new?
    create?
  end

  def update?
    update_lab.any? { |role| user.has_role?(role) }
  end

  def edit?
    update?
  end

  def destroy?
    destroy_lab.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  private

  def update_lab
    [ :admin ]
  end

  def show_lab
    [ :admin, :pharmacist, :pharmacist_assistant, :central_pharmacist ]
  end

  def create_lab
    [ :admin, :pharmacist ]
  end

  def destroy_lab
    [ :admin ]
  end
end
