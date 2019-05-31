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
    [ :admin, :farmaceutico, :auxiliar_farmacia ]
  end

  def show_pat
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero ]
  end

  def create_pat
    [ :admin, :farmaceutico ]
  end

  def destroy_pat
    [ :admin ]
  end
end
