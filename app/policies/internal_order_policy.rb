class InternalOrderPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medico, :enfermero)
  end

  def applicant_index?
    index?
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def create_applicant?
    new_applicant?
  end

  def new?
    create?
  end

  def update?
    unless ["en_camino", "entregado"].include? record.provider_status
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def edit?
    if (["solicitud_enviada", "proveedor_auditoria"].include? record.status) && record.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def edit_applicant?
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

  def new_provider?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def new_report?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end

  def generate_report?
    new_report?
  end

  def new_applicant?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
  end

  def send_provider?
    if (["solicitud_enviada", "proveedor_auditoria"].include? record.status) && record.provider_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def send_applicant?
    if record.applicant_sector == user.sector
      record.solicitud_auditoria? && user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
    end
  end

  def receive_applicant?
    if record.applicant_sector == user.sector
      record.provision_en_camino? && user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medic, :enfermero)
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
end
