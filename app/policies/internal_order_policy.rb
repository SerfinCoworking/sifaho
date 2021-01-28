class InternalOrderPolicy < ApplicationPolicy
  def provider_index?
    show?
  end

  def applicant_index?
    show?
  end

  def show?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
  end

  def new_provider?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def new_applicant?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def new_report?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end

  def create_applicant?
    new_applicant?
  end
  
  def create_provider?
    new_provider?
  end
  
  def edit_applicant?
    if record.solicitud_auditoria? && record.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end
  
  def edit_provider?
    if (["solicitud_enviada", "proveedor_auditoria"].include? record.status) && record.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def update_applicant?
    edit_applicant?
  end
  
  def update_provider?
    if ((["solicitud_enviada", "proveedor_auditoria"].include? record.status) && record.provider_sector == user.sector)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end
  
  def send_provider?
    update_provider?
  end

  def send_applicant?
    if record.solicitud_auditoria? && record.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def destroy?
    if record.solicitud? 
      if record.solicitud_auditoria? && record.applicant_sector == user.sector
        user.has_any_role?(:admin, :farmaceutico, :enfermero)
      end
    elsif record.provision? 
      if record.proveedor_auditoria? && record.provider_sector == user.sector
        user.has_any_role?(:admin, :farmaceutico, :enfermero)
      end
    end
  end

  def delete?
    destroy?
  end

  def generate_report?
    new_report?
  end

  def receive_applicant?
    if record.applicant_sector == user.sector && record.provision_en_camino? 
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def return_provider_status?
    if record.provider_sector == user.sector && record.provision_en_camino?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def return_applicant_status?
    if record.applicant_sector == user.sector && record.solicitud_enviada?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def nullify?
    if record.provider_sector == user.sector && record.solicitud? && (record.solicitud_enviada? || record.proveedor_auditoria?)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def show_applicant_fields?
    if record.solicitud_auditoria?
      record.solicitud? && (new_applicant? || edit_applicant?)
    end
  end
  
  def show_provider_fields?
    if record.provision?
      return new_provider? || edit_provider?
    elsif record.solicitud?
      return edit_provider?
    end
  end
end
