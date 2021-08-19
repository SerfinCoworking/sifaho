class ExternalOrderTemplateProviderPolicy < ExternalOrderTemplatePolicy
  
  def edit?(resource)
    if resource.owner_sector == user.sector && resource.provision?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def use_template?(resource)
    if resource.provision? && resource.owner_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end
end