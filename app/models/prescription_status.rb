class PrescriptionStatus < ApplicationRecord
  has_many :prescriptions

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
