class ChronicPrescriptionPolicy < ApplicationPolicy
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

  def update?
    edit?
  end
  
  def dispense_new?
    if record.pendiente? || record.dispensada_parcial?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end
  
  def dispense?
    dispense_new?
  end
  
  def return_dispensation?
    # no se puede retornar ninguna dispensacion, si la receta esta vencida
    !record.vencida?
  end

  def destroy?
    if record.pendiente?
      user.has_any_role?(:admin, :farmaceutico)
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
