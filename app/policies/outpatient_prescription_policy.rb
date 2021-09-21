class OutpatientPrescriptionPolicy < ApplicationPolicy
  def index?
    show?
  end

  def show?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
  end

  def new?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def create?
    new?
  end  
  
  def edit?
    if record.pendiente?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end

  def print?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end

  def update?
    edit?
  end
  
  def dispense?
    edit?
  end
  
  def return_dispensation?
    record.dispensada?
  end

  def destroy?
    unless record.dispensada?
      user.has_any_role?(:admin)
    end
  end

  def delete?
    destroy?
  end

  def nullify?
    if record.provider_sector == user.sector && record.solicitud? && (record.solicitud_enviada? || record.proveedor_auditoria?)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

end
