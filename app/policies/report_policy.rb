class ReportPolicy < ApplicationPolicy
  def index?
    show_roles.any? { |role| user.has_role?(role) }
  end

  def show?
    index? && ( user.sector == record.sector )
  end

  def create_supply_consumption_to_date?
    create_roles.any? { |role| user.has_role?(role) }
  end

  def new_supply_consumption_to_date?
    create_supply_consumption_to_date?
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
