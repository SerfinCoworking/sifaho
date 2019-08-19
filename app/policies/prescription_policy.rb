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

  def new_cronic?
    create?
  end

  def update?
    if record.pendiente? || record.dispensada_parcial?
      update_pres.any? { |role| user.has_role?(role) }
    end
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
    if record.provider_sector == user.sector
      dispense_pres.any? { |role| user.has_role?(role) }
    end
  end

  def return_status?
    if record.dispensada? && record.provider_sector == user.sector
      update_pres.any? { |role| user.has_role?(role) }
    end
  end

  def return_cronic_dispensation?
    if record.cronica? && record.cronic_dispensations.to_set.count > 0
      return_pres.any? { |role| user.has_role?(role) }
    end
  end


  private

  def return_pres
    [ :admin, :farmaceutico ]
  end

  def update_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia ]
  end

  def see_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic ]
  end

  def new_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :medic ]
  end

  def destroy_pres
    [ :admin, :farmaceutico ]
  end

  def dispense_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia ]
  end
end
