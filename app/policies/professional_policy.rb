class ProfessionalPolicy < ApplicationPolicy
  def index?
    show_pro.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def create?
    create_pro.any? { |role| user.has_role?(role) }
  end

  def new?
    create?
  end

  def update?
    update_pro.any? { |role| user.has_role?(role) }
  end

  def edit?
    update?
  end

  def destroy?
    destroy_pro.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  private

  def update_pro
    [ :admin ]
  end

  def show_pro
    [ :admin, :pharmacist, :pharmacist_assistant, :central_pharmacist ]
  end

  def create_pro
    [ :admin, :pharmacist ]
  end

  def destroy_pro
    [ :admin ]
  end
end
