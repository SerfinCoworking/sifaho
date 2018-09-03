class OrderingSupplyPolicy < ApplicationPolicy
  def index?
    see_pres.any? { |role| user.has_role?(role) }
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
    if record.provider_auditoria?
      edit_provider.any? { |role| user.has_role?(role) }
    else
      return false
    end
  end

  def destroy?
    destroy_pres.any? { |role| user.has_role?(role) }
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
    record.provider_aceptado? && send_order.any? { |role| user.has_role?(role) }
  end

  def send_applicant?
    record.provider_aceptado? && send_order.any? { |role| user.has_role?(role) }
  end

  def return_provider_status?
    if ["auditoria", "entregado"].include? record.provider_status
      return false
    else
      record.provider_sector == user.sector && return_status.any? { |role| user.has_role?(role) }
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
  def edit_provider
    [ :admin, :pharmacist ]
  end

  def new_provider
    [ :admin, :pharmacist ]
  end

  def send_order
    [ :admin, :pharmacist ]
  end

  def return_status
    [ :admin, :pharmacist ]
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
