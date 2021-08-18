class ExternalOrderProviderPolicy < ExternalOrderPolicy

  def index?
    show?
  end

  def new?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def create?
    new?
  end

  def edit?(resource)
    if (["solicitud_enviada", "proveedor_auditoria"].include?(resource.status)) && resource.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end

  def update?(resource)
    edit?(resource)
  end

  def destroy?(resource)
    # ['%iadmin %ifarmaceutico %ienfermero'].any? { |role| user.has_role?(role) } &&
    #   resource.solicitud? && resource.solicitud_auditoria? &&
    #   resource.applicant_sector == user.sector
  end

  # def delete?
  #   destroy?
  # end

  

  def can_send?(resource)
    if resource.provider_sector == user.sector
      resource.proveedor_aceptado? && send_order.any? { |role| user.has_role?(role) }
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

  def nullify?(resource)
    if (["solicitud_enviada"].include? resource.status) && resource.provider_sector == user.sector
      edit?(resource)
    end
  end

  def nullify_confirm?(resource)
    nullify?(resource)
  end
  ####### TO REVIEW ######


  # def return_status?
  #   if destroy_pres.any? { |role| user.has_role?(role) }
  #     if record.despacho?
  #       if record.proveedor_aceptado? || record.provision_en_camino?
  #         return record.provider_sector == user.sector
  #       end
  #     elsif record.solicitud_abastecimiento?
  #       if record.proveedor_aceptado?
  #         return record.provider_sector == user.sector
  #       elsif record.solicitud_enviada?
  #         return record.applicant_sector == user.sector
  #       elsif record.provision_en_camino?
  #         return record.provider_sector == user.sector
  #       end
  #     elsif record.recibo?
  #       return false
  #     end
  #   end 
  # end
  

  private
  
  def receive_order
    [ :admin, :farmaceutico ]
  end



  

  
  def new_report
    [ :admin, :farmaceutico ]
  end

  def send_order
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero ]
  end

  def return_status
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero ]
  end

  def update_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero ]
  end

  def see_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero, :medic ]
  end

  def new_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero ]
  end

  def destroy_pres
    [ :admin, :farmaceutico, :enfermero ]
  end

  def dispense_pres
    [ :admin, :farmaceutico, :auxiliar_farmacia, :enfermero ]
  end
end
