class SupplyLotPolicy < ApplicationPolicy
  def index?
    see_sl.any? { |role| user.has_role?(role) }
  end

  def trash_index?
    see_sl.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def create?
    new_sl.any? { |role| user.has_role?(role) }
  end

  def new?
    create?
  end

  def update?
    new_sl.any? { |role| user.has_role?(role) }
  end

  def edit?
    update?
  end

  def destroy?
    destroy_sl.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  def restore?
    destroy?
  end

  def purge?
    purge_sl.any? { |role| user.has_role?(role) }
  end

  private

  def see_sl
    [ :admin, :pharmacist, :pharmacist_assistant, :responsable, :central_pharmacist, :medic ]
  end

  def new_sl
    [ :admin, :central_pharmacist ]
  end

  def destroy_sl
    [ :admin, :central_pharmacist ]
  end

  def purge_sl
    [ :admin ]
  end
end
