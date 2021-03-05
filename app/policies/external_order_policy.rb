class ExternalOrderPolicy < ApplicationPolicy
  def provider_index?
    show?
  end

  def applicant_index?
    show?
  end

  def show?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
  end

  # new version
  def new_applicant?
    user.has_any_role?(:admin, :farmaceutico, :enfermero) 
  end
  
  def create_applicant?
    new_applicant?
  end
  
  def edit_applicant?
    if record.solicitud_auditoria? && record.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end

  def update_applicant?
    edit_applicant?
  end
  
  def new_provider?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end
  
  def create_provider?
    new_provider?
  end
  
  def edit_provider?
    if (["solicitud_enviada", "proveedor_auditoria"].include? record.status) && record.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :enfermero)
    end
  end
  
  def update_provider?
    edit_provider?
  end

  def accept_provider?
    if record.proveedor_auditoria? && record.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def show_applicant_fields?
    if record.solicitud_auditoria?
     record.solicitud? && (new_applicant? || edit_applicant?)
    end
  end

  def show_provider_fields?
    # asd
    if record.provision?
      return new_provider? || edit_provider?
    else
      return edit_provider?
    end
  end
  #  end new version


  def new_report?
    new_report.any? { |role| user.has_role?(role) }
  end

  def generate_report?
    new_report?
  end

  def destroy?
    if destroy_pres.any? { |role| user.has_role?(role) }
      if record.provision? && record.proveedor_auditoria?
        return record.provider_sector == user.sector
      elsif record.solicitud? && record.solicitud_auditoria?
        return record.applicant_sector == user.sector
      end 
    end 
  end

  def delete?
    destroy?
  end

  def receive?
    dispense_pres.any? { |role| user.has_role?(role) }
  end
  
  def send_provider?
    if record.provider_sector == user.sector
      record.proveedor_aceptado? && send_order.any? { |role| user.has_role?(role) }
    end
  end

  def receive_applicant?
    if record.applicant_sector == user.sector && record.provision_en_camino? 
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def send_applicant?
    if record.solicitud_auditoria? && record.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end
  
  def return_provider_status?
    if record.provider_sector == user.sector && record.proveedor_aceptado?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def return_applicant_status?
    if record.applicant_sector == user.sector && record.solicitud_enviada?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  ####### TO REVIEW ######

  def receive_order?
    if record.applicant_sector == user.sector && receive_order.any? { |role| user.has_role?(role) }
      if record.recibo?
        record.recibo_auditoria?
      elsif record.despacho? || record.solicitud_abastecimiento?
        record.provision_en_camino?
      end
    end
  end

  def return_status?
    if destroy_pres.any? { |role| user.has_role?(role) }
      if record.despacho?
        if record.proveedor_aceptado? || record.provision_en_camino?
          return record.provider_sector == user.sector
        end
      elsif record.solicitud_abastecimiento?
        if record.proveedor_aceptado?
          return record.provider_sector == user.sector
        elsif record.solicitud_enviada?
          return record.applicant_sector == user.sector
        elsif record.provision_en_camino?
          return record.provider_sector == user.sector
        end
      elsif record.recibo?
        return false
      end
    end 
  end
  
  def nullify?
    if (["solicitud_enviada"].include? record.status) && record.provider_sector == user.sector
      edit_provider?
    end
  end

  def nullify_confirm?
    nullify?
  end

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
