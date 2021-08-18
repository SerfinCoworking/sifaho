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
    ['%iadmin %ifarmaceutico %ienfermero'].any? { |role| user.has_role?(role) } &&
      resource.solicitud? && resource.solicitud_auditoria? &&
      resource.applicant_sector == user.sector
  end

  def delete?
    destroy?
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
