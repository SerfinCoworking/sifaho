class InternalOrderPolicy < ApplicationPolicy
  def new?
    record.sector_id == user.sector_id && (user.has_role? :internal_order)
  end

  def new?
    user.present? && (user.has_role? :internal_order)
  end

  def edit?
    record.sector_id == user.sector_id && (user.has_role? :internal_order)
  end

  def destroy?
    record.user == user && (user.has_role? :internal_order)
  end
end
