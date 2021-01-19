class ReceiptPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin, :farmaceutico)
  end

  def new?
    create?
  end

  def update?
    edit?
  end

  def edit?
    if record.auditoria? && record.applicant_sector == user.sector
      user.has_any_role?(:admin, :farmaceutico)
    end
  end

  def destroy?
    if user.has_any_role?(:admin, :farmaceutico) && record.auditoria?
      return record.applicant_sector == user.sector
    end 
  end

  def delete?
    destroy?
  end

  def receive?
    user.has_any_role?(:admin, :farmaceutico)
  end
end
