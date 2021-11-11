class ExternalOrderProviderPolicy < ExternalOrderPolicy

  def new?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def create?
    new?
  end

  def edit?(resource)
    if (resource.solicitud_enviada? || resource.proveedor_auditoria?) && resource.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end

  def edit_provider_on_solicitud?(resource)
    unless resource.solicitud? && resource.solicitud_enviada? && resource.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end

  def update?(resource)
    edit?(resource)
  end

  def destroy?(resource)
    %i['admin farmaceutico enfermero'].any? { |role| user.has_role?(role) } &&
      resource.provision? && resource.proveedor_auditoria? && resource.provider_sector == user.sector
  end

  def edit_products?(resource)
    return unless %w[solicitud_enviada proveedor_auditoria].any?(resource.status) && resource.provider_sector == user.sector
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def can_send?(resource)
    if resource.proveedor_aceptado? && resource.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def rollback_order?(resource)
    if resource.provider_sector == user.sector && resource.proveedor_aceptado?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def accept_order?(resource)
    if resource.proveedor_auditoria? && resource.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def nullify_order?(resource)
    if (['solicitud_enviada'].include? resource.status) && resource.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end
end