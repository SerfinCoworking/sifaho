class ReceiptPolicy < ApplicationPolicy
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
    edit?
  end

  def edit?
    if record.auditoria? && record.applicant_sector == user.sector
      edit_provider.any? { |role| user.has_role?(role) }
    end
  end

  def destroy?
    if destroy_pres.any? { |role| user.has_role?(role) } && record.auditoria?
      return record.applicant_sector == user.sector
    end 
  end

  def delete?
    destroy?
  end

  def receive?
    dispense_pres.any? { |role| user.has_role?(role) }
  end
  
  private
  def create_receipt
    [ :admin, :farmaceutico ]
  end
  
  def receive_order
    [ :admin, :farmaceutico ]
  end

  def edit_provider
    [ :admin, :farmaceutico, :enfermero ]
  end

  def edit_applicant
    [ :admin, :farmaceutico, :enfermero ]
  end

  def new_provider
    [ :admin, :farmaceutico, :enfermero ]
  end

  def new_applicant
    [ :admin, :farmaceutico, :enfermero ]
  end

  def new_receipt
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
