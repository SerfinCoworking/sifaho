class PatientType < ApplicationRecord
  # Relaciones
  has_many :patients

  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end
end
