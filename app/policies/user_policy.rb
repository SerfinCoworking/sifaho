class UserPolicy < ApplicationPolicy

  def index?
    index_user.any? { |role| user.has_role?(role) }
  end

  private

  def index_user
    [ :admin ]
  end
end
