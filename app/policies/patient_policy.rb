class PatientPolicy < ApplicationPolicy
  def index?
    show_pat.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def create?
    create_pat.any? { |role| user.has_role?(role) }
  end

  def new?
    create?
  end

  def update?
    update_pat.any? { |role| user.has_role?(role) }
  end

  def edit?
    update?
  end

  def destroy?
    destroy_pat.any? { |role| user.has_role?(role) }
  end

  private

  def update_pat
    [ :admin, :pharmacist ]
  end

  def show_pat
    [ :admin, :pharmacist, :pharmacist_assistant, :central_pharmacist ]
  end

  def create_pat
    [ :admin, :pharmacist, :pharmacist_assistant, :central_pharmacist ]
  end

  def destroy_pat
    [ :admin ]
  end
end
