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
    record.sector_id == user.sector_id && new_sl.any? { |role| user.has_role?(role) }
  end

  def edit?
    update?
  end

  def destroy?
    record.sector_id == user.sector_id && destroy_sl.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  def restore?
    destroy?
  end

  private

  def see_sl
    [ :admin, :pharmacist, :pharmacist_assistant, :responsable, :central_pharmacist, :medic ]
  end

  def new_sl
    [ :admin, :pharmacist, :pharmacist_assistant ]
  end

  def destroy_sl
    [ :admin, :pharmacist, :central_pharmacist, :responsable ]
  end
end
