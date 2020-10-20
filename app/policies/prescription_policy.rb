class PrescriptionPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic)
  end

  def new?
    create?
  end

  def new_cronic?
    create?
  end

  def update?
    if record.pendiente? || record.dispensada_parcial?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end

  def edit?
    update?
  end

  def destroy?
    unless record.dispensada? || record.dispensada_parcial?
      user.has_any_role?(:admin, :farmaceutico)
    end
  end

  def delete?
    destroy?
  end

  def dispense?
    if record.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end

  def return_ambulatory_dispensation?
    if record.dispensada? && (record.provider_sector == user.sector) && record.ambulatoria?
      user.has_any_role?(:admin, :farmaceutico)
    end
  end

  def return_cronic_dispensation?
    if record.cronica? && record.cronic_dispensations.to_set.count > 0
      user.has_any_role?(:admin, :farmaceutico)
    end
  end
end
