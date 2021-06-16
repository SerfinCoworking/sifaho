class BedPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :enfermero)
  end

  def bed_map?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin)
  end

  def create_applicant?
    new_applicant?
  end

  def new?
    create?
  end

  def update?
    user.has_any_role?(:admin, :enfermero)
  end

  def edit?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def destroy?
    unless record.patient.present?
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end

  def delete?
    destroy?
  end

  def admit_patient?
    if record.disponible?
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end

  def discharge_patient?
    if record.ocupada?
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end
end
