class PrescriptionPolicy < ApplicationPolicy
  def index?
    see_pres.any? { |role| user.has_role?(role) }
  end

  def show?
    index?
  end

  def create?
    new_pres.any? { |role| user.has_role?(role) }
  end

  def new?
    create?
  end

  def update?
    update_pres.any? { |role| user.has_role?(role) }
  end

  def edit?
    update?
  end

  def destroy?
    destroy_pres.any? { |role| user.has_role?(role) }
  end

  def delete?
    destroy?
  end

  def dispense?
    dispense_pres.any? { |role| user.has_role?(role) }
  end


  private

  def update_pres
    [ :pharmacist, :pharmacist_assistant ]
  end

  def see_pres
    [ :admin, :pharmacist, :pharmacist_assistant, :central_pharmacist, :medic ]
  end

  def new_pres
    [ :pharmacist, :pharmacist_assistant, :medic ]
  end

  def destroy_pres
    [ :pharmacist ]
  end

  def dispense_pres
    [ :pharmacist, :pharmacist_assistant ]
  end
end
