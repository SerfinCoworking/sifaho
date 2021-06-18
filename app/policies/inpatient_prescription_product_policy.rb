class InpatientPrescriptionProductPolicy < ApplicationPolicy
  # Solo podran editarse si, aun no ha sido proveido el producto
  # Si es un nuevo objecto
  # Si es el profesional que lo creo
  # Si la fecha recetada es la misma o mayor que la actual 
  def edit_parent_product?
    # review
    if (record.sin_proveer? && (record.prescribed_by_id == user.id)) || record.new_record?
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
