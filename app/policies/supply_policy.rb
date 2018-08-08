class SupplyPolicy < ApplicationPolicy

  def index?
    index_sup.any? { |role| user.has_role?(role) }
  end

  def trash_index?
    trash_index_sup.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def create?
    user.has_role? :central_pharmacist
  end

  def new?
    create?
  end

  def update?
    user.has_role? :central_pharmacist
  end

  def edit?
    update?
  end

  def destroy?
    user.has_role? :central_pharmacist
  end

  def delete?
    destroy?
  end

  def restore?
    destroy?
  end

  private

  def index_sup
    [ :admin, :pharmacist, :pharmacist_assistant, :responsable, :medic, :central_pharmacist ]
  end

  def trash_index_sup
    [ :admin, :pharmacist, :pharmacist_assistant, :responsable, :medic, :central_pharmacist ]
  end

  def see_supplies
    [ :admin, :pharmacist, :pharmacist_assistant, :responsable, :medic, :central_pharmacist ]
  end
end
