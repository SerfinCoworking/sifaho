class BedroomPolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :enfermero)
  end

  def bed_map?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
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

  def update?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def edit?
    user.has_any_role?(:admin, :farmaceutico, :enfermero)
  end

  def destroy?
    if record.solicitud? 
      if record.solicitud_auditoria? && record.applicant_sector == user.sector
        user.has_any_role?(:admin, :enfermero)
      end
    elsif record.provision? 
      if record.proveedor_auditoria? && record.provider_sector == user.sector
        user.has_any_role?(:admin, :enfermero)
      end
    end
  end

  def delete?
    destroy?
  end
end
