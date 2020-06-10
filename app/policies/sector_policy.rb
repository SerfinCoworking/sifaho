class SectorPolicy < ApplicationPolicy
  def index?
    show_roles.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def new?
    destroy_roles.any? { |role| user.has_role?(role) }
  end

  def edit?
    destroy_roles.any? { |role| user.has_role?(role) }
  end


  def destroy?
    destroy_roles.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  private

  def show_roles
    [ :admin, :farmaceutico, :auxiliar_farmacia, :farmaceutico_central ]
  end

  def create_roles
    [ :admin, :farmaceutico, :auxiliar_farmacia ]
  end

  def destroy_roles
    [ :admin ]
  end
end
