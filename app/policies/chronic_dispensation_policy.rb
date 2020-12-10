class ChronicDispensationPolicy < ApplicationPolicy

  def new?
    if record.chronic_prescription.pendiente? || record.chronic_prescription.dispensada_parcial?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end

  def create?
    new?
  end

  def return_dispensation?
    unless record.chronic_prescription.vencida? 
      diff_in_hours = (DateTime.now.to_time - record.created_at.to_time) / 1.hours
      if diff_in_hours < 24
        user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
      end
    end
  end

  def return_dispensation_modal?
    return_dispensation?
  end
  
end
