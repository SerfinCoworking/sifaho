class InternalOrderProductPolicy < ApplicationPolicy
  def edit_request_quantity?
    if record.is_provision? || (!record.is_provision? && record.new_record?)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    elsif !record.is_provision? && record.get_order.solicitud_auditoria?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    end
  end

  def edit_product?
    if record.is_provision? || (!record.is_provision? && record.new_record?)
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    elsif !record.is_provision? && record.get_order.solicitud_auditoria?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    end
  end

  def remove_association?
    if record.is_provision? || record.new_record?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    elsif !record.is_provision? && record.get_order.solicitud_auditoria?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :central_farmaceutico, :medic, :enfermero)
    end
  end
end
