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
    unless record.dispensada?
      destroy_pres.any? { |role| user.has_role?(role) }
    end
  end

  def delete?
    destroy?
  end

  def dispense?
    dispense_pres.any? { |role| user.has_role?(role) }
  end

  def return_status?
    if record.dispensada? && record.created_by.sector == user.sector
      update_pres.any? { |role| user.has_role?(role) }
    end
  end


  private

  def update_pres
    [ :admin, :pharmacist, :pharmacist_assistant ]
  end

  def see_pres
    [ :admin, :pharmacist, :pharmacist_assistant, :central_pharmacist, :medic ]
  end

  def new_pres
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def destroy_pres
    [ :admin, :pharmacist ]
  end

  def dispense_pres
    [ :admin, :pharmacist, :pharmacist_assistant ]
  end
end
