class InpatientPrescriptionProductPolicy < ApplicationPolicy

  def edit_parent_product?
    if record.sin_proveer? || record.new_record?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    end
  end

  def edit_child_product?
    if record.parent.sin_proveer?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    end
  end

  def remove_association?
    edit_parent_product?
  end


  def destroy?
    if record.sin_proveer?
      user.has_any_role?(:admin, :farmaceutico)
    end
  end
  
  def delete?
    destroy?
  end

end
