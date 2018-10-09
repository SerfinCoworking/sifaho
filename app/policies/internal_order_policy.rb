class InternalOrderPolicy < ApplicationPolicy
  def index?
    see_pres.any? { |role| user.has_role?(role) }
  end

  def applicant_index?
    index?
  end

  def show?
    index?
  end

  def create?
    new_pres.any? { |role| user.has_role?(role) }
  end

  def create_applicant?
    new_applicant?
  end

  def new?
    create?
  end

  def update?
    unless ["en_camino", "entregado"].include? record.provider_status
      update_pres.any? { |role| user.has_role?(role) }
    end
  end

  def edit?
    if (["solicitud_enviada", "proveedor_auditoria"].include? record.status) && record.provider_sector == user.sector
      edit_provider.any? { |role| user.has_role?(role) }
    end
  end

  def edit_applicant?
    if record.solicitud_auditoria? && record.applicant_sector == user.sector
      edit_applicant.any? { |role| user.has_role?(role) }
    end
  end

  def destroy?
    if record.solicitud? 
      if record.solicitud_auditoria? && record.applicant_sector == user.sector
        destroy_pres.any? { |role| user.has_role?(role) }
      end
    elsif record.provision? 
      if record.proveedor_auditoria? && record.provider_sector == user.sector
        destroy_pres.any? { |role| user.has_role?(role) }
      end
    end
  end

  def delete?
    destroy?
  end

  def receive?
    dispense_pres.any? { |role| user.has_role?(role) }
  end

  def new_provider?
    new_provider.any? { |role| user.has_role?(role) }
  end

  def new_applicant?
    new_applicant.any? { |role| user.has_role?(role) }
  end

  def send_provider?
    if (["solicitud_enviada", "proveedor_auditoria"].include? record.status) && record.provider_sector == user.sector
      send_order.any? { |role| user.has_role?(role) }
    end
  end

  def send_applicant?
    if record.applicant_sector == user.sector
      record.solicitud_auditoria? && send_order.any? { |role| user.has_role?(role) }
    end
  end

  def receive_applicant?
    if record.applicant_sector == user.sector
      record.provision_en_camino? && receive_applicant.any? { |role| user.has_role?(role) }
    end
  end

  def return_provider_status?
    if record.provider_sector == user.sector && record.provision_en_camino?
      return_status.any? { |role| user.has_role?(role) }
    end
  end

  def return_applicant_status?
    if record.applicant_sector == user.sector && record.solicitud_enviada?
      return_status.any? { |role| user.has_role?(role) }
    end
  end

  private
  def receive_applicant
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def edit_provider
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def edit_applicant
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def new_provider
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def new_applicant
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def send_order
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def return_status
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def update_pres
    [ :admin, :pharmacist, :pharmacist_assistant ]
  end

  def see_pres
    [ :admin, :pharmacist, :pharmacist_assistant, :central_pharmacist, :medic ]
  end

  def new_pres
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def destroy_pres
    [ :admin, :pharmacist ]
  end

  def dispense_pres
    [ :admin, :pharmacist, :pharmacist_assistant ]
  end
end
