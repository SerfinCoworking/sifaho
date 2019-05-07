class SectorSupplyLotPolicy < ApplicationPolicy
  def index?
    see_ssl.any? { |role| user.has_role?(role) }
  end

  def trash_index?
    see_ssl.any? { |role| user.has_role?(role) }
  end

  def group_by_supply?
    see_ssl.any? { |role| user.has_role?(role) }
  end

  def lots_for_supply?
    see_ssl.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def create?
    new_ssl.any? { |role| user.has_role?(role) }
  end

  def new?
    create?
  end

  def update?
    new_ssl.any? { |role| user.has_role?(role) }
  end

  def edit?
    update?
  end

  def destroy?
    destroy_ssl.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  def restore?
    destroy?
  end

  def purge?
    purge_ssl.any? { |role| user.has_role?(role) }
  end

  private

  def see_ssl
    [ :admin, :farmaceutico, :enfermero ]
  end

  def new_ssl
    [ :admin, :farmaceutico, :enfermero ]
  end

  def destroy_ssl
    [ :admin, :farmaceutico, :enfermero ]
  end

  def purge_ssl
    [ :admin ]
  end
end
