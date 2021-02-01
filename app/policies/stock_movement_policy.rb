class StockMovementPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin)
  end
end
