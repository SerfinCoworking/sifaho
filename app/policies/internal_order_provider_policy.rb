class InternalOrderProviderPolicy < InternalOrderPolicy
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
    if (["solicitud_enviada", "proveedor_auditoria"].include? resource.status) && resource.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def edit_products?(resource)
    return unless %w[solicitud_enviada proveedor_auditoria].any?(resource.status) && resource.provider_sector == user.sector

    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def update?(resource)
    edit?(resource)
  end

  def can_send?(resource)
    update?(resource)
  end

  def destroy?(resource)
    if resource.proveedor_auditoria? && resource.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end

  def generate_report?
    new_report?
  end

  def rollback_order?(resource)
    if resource.provider_sector == user.sector && resource.provision_en_camino?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def nullify_order?(resource)
    if resource.provider_sector == user.sector && resource.solicitud? && (resource.solicitud_enviada? || resource.proveedor_auditoria?)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end
end
