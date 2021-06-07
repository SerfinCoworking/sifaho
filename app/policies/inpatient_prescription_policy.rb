class InpatientPrescriptionPolicy < ApplicationPolicy
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
      # && (DateTime.now.to_time < record.expiry_date)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end
  
  def update?
    edit?
  end

  def delivery?
    if record.pendiente? || record.parcialmente_dispensada?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end
  
  def update_with_delivery?
    delivery?
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
