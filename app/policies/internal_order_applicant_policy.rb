class InternalOrderApplicantPolicy < InternalOrderPolicy

  def index?
    show?
  end

  def new?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def new_report?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end

  def create?
    new?
  end

  def edit?(resource)
    return unless resource.solicitud_auditoria? && resource.applicant_sector == user.sector

    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def edit_products?(resource)
    return unless resource.solicitud_auditoria? && resource.applicant_sector == user.sector

    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def update?(resource)
    edit?(resource)
  end

  def dispatch_order?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def destroy?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end

  def generate_report?
    new_report?
  end

  def receive_order?(resource)
    if resource.applicant_sector == user.sector && resource.provision_en_camino? 
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def rollback_order?(resource)
    if resource.applicant_sector == user.sector && resource.solicitud_enviada?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end
end
