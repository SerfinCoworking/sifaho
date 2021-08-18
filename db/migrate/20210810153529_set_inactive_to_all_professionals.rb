class SetInactiveToAllProfessionals < ActiveRecord::Migration[5.2]
  def up
    Professional.find_each do |professional|
      professional.is_active = false
      professional.save
    end
  end

  def down
    Professional.find_each do |professional|
      professional.is_active = true
      professional.save
    end
  end
end
