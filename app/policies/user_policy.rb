class UserPolicy < ApplicationPolicy

  def index?
    index_user.any? { |role| user.has_role?(role) }
  end

  def update?
    record == user || update.any? { |role| user.has_role?(role) }
  end

  def change_sector?
    record.sectors.count > 1 && self.update? 
  end

  private

  def index_user
    [ :admin ]
  end

  def update
    [ :admin ]
  end
end
