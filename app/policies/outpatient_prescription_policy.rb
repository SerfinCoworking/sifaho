class OutpatientPrescriptionPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_permission?(:read_outpatient_recipes)
  end

  def new?
    user.has_permission?(:create_outpatient_recipes)
  end

  def create?
    new?
  end

  def edit?
    user.has_permission?(:update_outpatient_recipes) if record.pendiente?
  end

  def print?
    show?
  end

  def update?
    edit?
  end

  def dispense?
    user.has_permission?(:dispense_outpatient_recipes)
  end

  def return_dispensation?
    user.has_permission?(:return_outpatient_recipes) if record.dispensada?
  end

  def destroy?
    user.has_permission?(:destroy_outpatient_recipes) unless record.dispensada?
  end

  def delete?
    destroy?
  end
end
