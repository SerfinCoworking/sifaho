class InternalOrderPolicy < ApplicationPolicy
  def index?
    index_io.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def create?
    create_io.any? { |role| user.has_role?(role) }
  end

  def new?
    create?
  end

  def update?
    record.applicant_id == user.id || update_io.any? { |role| user.has_role?(role) }
  end

  def edit?
    update?
  end

  def destroy?
    destroy_io.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  def deliver?
    deliver_io.any? { |role| user.has_role?(role) }
  end

  def new_deliver?
    deliver?
  end

  private

  def deliver_io
    [ :admin, :pharmacist, :pharmacist_assistant ]
  end

  def update_io
    [ :admin, :pharmacist, :pharmacist_assistant ]
  end

  def index_io
    [ :admin, :pharmacist, :pharmacist_assistant, :responsable, :medic ]
  end

  def create_io
    [ :admin, :pharmacist, :pharmacist_assistant, :responsable]
  end

  def destroy_io
    [ :admin, :pharmacist ]
  end
end
