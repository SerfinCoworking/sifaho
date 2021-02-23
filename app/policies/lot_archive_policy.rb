class LotArchivePolicy < ApplicationPolicy
  def index?
    user.has_any_role?(:admin)
  end

  def show_lot_archive?
    index?
  end

  def return_archive?
    unless record.retornado?      
      diff_in_hours = (DateTime.now.to_time - record.created_at.to_time) / 1.hours
      if diff_in_hours < 48
        user.has_any_role?(:admin)
      end
    end
  end
  
  def return_archive_modal?
    return_archive?
  end
end
