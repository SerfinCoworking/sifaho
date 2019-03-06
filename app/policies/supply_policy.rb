class SupplyPolicy < ApplicationPolicy

  def index?
    index_sup.any? { |role| user.has_role?(role) }
  end

  def trash_index?
    trash_index_sup.any? { |role| user.has_role?(role) }
  end

  def lots_for_supply?
    index_sup.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def create?
    create_sup.any? { |role| user.has_role?(role) }
  end

  def new?
    create?
  end

  def update?
    update_sup.any? { |role| user.has_role?(role) }
  end

  def edit?
    update?
  end

  def destroy?
    destroy_sup.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  def restore?
    destroy?
  end

  private

  def index_sup
    [ :admin, :farmaceutico, :auxiliar_farmacia, :responsable, :medico, :farmaceutico_central ]
  end

  def trash_index_sup
    [ :admin, :farmaceutico, :auxiliar_farmacia, :responsable, :medico, :farmaceutico_central ]
  end

  def see_supplies
    [ :admin, :farmaceutico, :auxiliar_farmacia, :responsable, :medico, :farmaceutico_central ]
  end

  def destroy_sup
    [ :admin, :farmaceutico_central ]
  end

  def update_sup
    [ :admin, :central_pharmacist ]
  end

  def create_sup
    [ :admin, :central_pharmacist ]
  end
end
