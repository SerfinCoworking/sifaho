class AreaPolicy < ApplicationPolicy
    def index?
      user.has_any_role?(:admin, :enfermero, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    end
  
    def show?
      index?
    end
  
    def create?
      user.has_any_role?(:admin)
    end
  
    def create_applicant?
      new_applicant?
    end
  
    def new?
      create?
    end
  end
  