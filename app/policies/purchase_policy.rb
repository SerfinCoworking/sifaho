class PurchasePolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin)
  end

  def new?
    create?
  end

  def update?
    edit?
  end
  
  def edit?
    user.has_any_role?(:admin) && record.inicial? || record.auditoria?
  end
  
  def set_products?
    record.inicial? || record.auditoria?
  end
  
  def receive_purchase?
    record.auditoria?
  end

  def destroy?
    user.has_any_role?(:admin) && record.inicial? || record.auditoria?
  end

  def delete?
    destroy?
  end
end
