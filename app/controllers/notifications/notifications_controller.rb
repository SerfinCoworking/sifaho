module Notifications
  class NotificationsController < Notifications::ApplicationController
    def index
      @notifications = notifications.includes(:actor).order('id desc').page(params[:page]).per_page(15)

      # unread_ids = @notifications.reject(&:read?).select(&:id)
      # Notification.read!(unread_ids)

      @notification_groups = @notifications.group_by { |note| note.created_at.strftime("%d/%m/%Y") }
    end

    def set_as_read()
      @notification_id = params[:id]
      Notification.read!(@notification_id)
      respond_to do |format|
        format.js 
      end
    end

    def clean
      notifications.delete_all
      redirect_to notifications_path
    end

    private

    def notifications
      raise "You need reqiure user login for /notifications page." unless current_user
      Notification.where(user_id: current_user.id)
    end
  end
end
