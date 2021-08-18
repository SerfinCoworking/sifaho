class ExternalOrderApplicantPolicy < ExternalOrderPolicy

  def index?
    show?
  end

  # new version
  def new?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def create?
    new?
  end

  def edit?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end

  def update?(resource)
    edit?(resource)
  end

  def destroy?(resource)
    %i['admin farmaceutico enfermero'].any? { |role| user.has_role?(role) } &&
      resource.solicitud? && resource.solicitud_auditoria? && resource.applicant_sector == user.sector
  end

  def receive?
    dispense_pres.any? { |role| user.has_role?(role) }
  end

  def receive_order?(resource)
    if resource.applicant_sector == user.sector && resource.provision_en_camino? 
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def can_send?(resource)
    if resource.solicitud_auditoria? && resource.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def rollback_order?(resource)
    if resource.applicant_sector == user.sector && resource.solicitud_enviada?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

end
