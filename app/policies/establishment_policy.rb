class EstablishmentPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico)
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
    user.has_any_role?(:admin, :farmaceutico)
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

  private

  def update_lab
    [ :admin ]
  end

  def show_lab
    [ :admin, :farmaceutico, :auxiliar_farmacia, :farmaceutico_central ]
  end

  def create_lab
    [ :admin, :farmaceutico ]
  end

  def destroy_lab
    [ :admin ]
  end
end
