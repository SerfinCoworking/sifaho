class SectorSupplyLotPolicy < ApplicationPolicy
  def index?
    see_ssl.any? { |role| user.has_role?(role) }
  end

  def trash_index?
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

  private

  def see_ssl
    [ :admin, :pharmacist, :pharmacist_assistant, :responsable, :central_pharmacist, :medic ]
  end

  def new_ssl
    [ :admin, :pharmacist, :pharmacist_assistant ]
  end

  def destroy_ssl
    [ :admin, :pharmacist, :central_pharmacist, :responsable ]
  end
end
