class InpatientPrescriptionProductPolicy < ApplicationPolicy
  
  def edit_product?
    unless record.activo?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    end
  end
  
  def remove_association?
    edit_product?
  end


  def destroy?
    if record.activo?
      user.has_any_role?(:admin, :farmaceutico)
    end
  end
  
  def delete?
    destroy?
  end

end
