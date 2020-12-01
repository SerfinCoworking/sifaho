class ChronicDispensationPolicy < ApplicationPolicy

  def new?
    if record.chronic_prescription.pendiente? || record.chronic_prescription.dispensada_parcial?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end

  def create?
    new?
  end  
  
end
