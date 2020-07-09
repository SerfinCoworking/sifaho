class ApplicationController < ActionController::Base
  before_action :notifiction_set_as_read, only: [:show]

  rescue_from DeviseLdapAuthenticatable::LdapException do |exception|
    render :text => exception, :status => 500
  end
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  #before_action :configure_permitted_parameters, if: :devise_controller?
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def user_not_authorized
    flash[:error] = "Usted no está autorizado para realizar esta acción."
    redirect_to(request.referrer || root_path)
  end

  protected
    
    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit({ roles: [] }, :password, :password_confirmation, :username) }
    end
    
  private
    # Marcamos la notificacion comoo leida
    def notifiction_set_as_read
      if params[:notification_id].present?
        Notification.read!(params[:notification_id])
      end
    end
  
end
