class LotStockPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end

  def show?
    index?
  end

  def new_archive?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia) && record.quantity > 0
  end
  
  def create_archive?
    new_archive?
  end
end
