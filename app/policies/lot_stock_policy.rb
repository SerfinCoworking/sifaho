class LotStockPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end
  
  def lot_stocks_by_stock?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end

  def show?
    index?
  end
end
