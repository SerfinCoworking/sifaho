class OriginalChronicPrescriptionProductPolicy < ApplicationPolicy
  # Policy para editar producto recetado en Receta Crónica
  # Si, la receta fue "dispensada parcial", entonces no debemos dejar que se modifiquen los productos ya cargados
  # De lo contrario, si la receta esta pendiente, entonces permitimos que se pueda editar el producto recetado
  def edit?
    if record.chronic_prescription.dispensada_parcial? && record.persisted?
      user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
    end
  end
 
end
