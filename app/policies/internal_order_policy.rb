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

  def new?
    create?
  end

  def update?
    unless ["en_camino", "entregado"].include? record.provider_status
      update_pres.any? { |role| user.has_role?(role) }
    end
  end

  def edit?
    if record.provider_auditoria? && record.provider_sector == user.sector
      edit_provider.any? { |role| user.has_role?(role) }
    else
      return false
    end
  end

  def destroy?
    unless record.provider_entregado?
      destroy_pres.any? { |role| user.has_role?(role) }
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

  def send_provider?
    if record.provider_sector == user.sector
      record.provider_auditoria? && send_order.any? { |role| user.has_role?(role) }
    end
  end

  def send_applicant?
    if record.applicant_sector == user.sector
      record.applicant_borrador? && send_order.any? { |role| user.has_role?(role) }
    end
  end

  def receive_applicant?
    if record.applicant_sector == user.sector
      record.applicant_en_camino? && receive_applicant.any? { |role| user.has_role?(role) }
    end
  end

  def return_provider_status?
    if record.provider_sector == user.sector && record.provider_en_camino?
      return_status.any? { |role| user.has_role?(role) }
    end
  end

  def return_applicant_status?
    if record.applicant_sector == user.sector && record.applicant_enviado?
      return_status.any? { |role| user.has_role?(role) }
    end
  end

  def return_applicant_status?
    if ["auditoria", "enviado"].include? record.applicant_status
      return false
    else
      record.applicant_sector == user.sector && return_status.any? { |role| user.has_role?(role) }
    end
  end



  private
  def receive_applicant
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def edit_provider
    [ :admin, :pharmacist, :pharmacist_assistant, :medic ]
  end

  def new_provider
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
