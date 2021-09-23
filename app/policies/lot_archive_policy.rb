class LotArchivePolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :medico, :enfermero)
  end

  def show?
    index?
  end

  def new?
    user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia)
  end

  def create?
    new?
  end

  def return_archive?
    unless record.retornado?
      diff_in_hours = (DateTime.now.to_time - record.created_at.to_time) / 1.hours
      if diff_in_hours < 48
        user.has_any_role?(:admin, :farmaceutico, :auxiliar_farmacia, :enfermero)
      end
    end
  end

  def return_archive_modal?
    return_archive?
  end
end
