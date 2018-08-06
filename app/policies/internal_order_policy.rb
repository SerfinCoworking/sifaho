class InternalOrderPolicy < ApplicationPolicy
  def new?
    user.present? && (user.has_role? :internal_order)
  end

  def edit?
    record.responsable_id == user.id && (user.has_role? :internal_order)
  end

  def destroy?
    record.responsable_id == user.id && (user.has_role? :internal_order)
  end
end
