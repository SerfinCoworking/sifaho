class PatientProductStateReportPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :reportes_provincia)
  end

  def show?
    index?
  end

  def create?
    user.has_any_role?(:admin, :reportes_provincia)
  end

  def new?
    create?
  end
end
