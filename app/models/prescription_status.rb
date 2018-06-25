class PrescriptionStatus < ApplicationRecord
  # Relaciones
  has_many :prescriptions

  def is_dispense?
    self.name == "Dispensada"
  end

  def label
    if self.name == "Pendiente"
      return "default"
    elsif self.name == "Dispensada"
      return "success"
    elsif self.name == "Vencida"
      return "danger"
    end
  end
end
