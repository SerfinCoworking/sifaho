class ErrorsController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def not_found
    flash[:error] = "No existe la página a la que intenta acceder."
    redirect_to(request.referrer || root_path)
  end

  def internal_server_error
    flash[:error] = "Error del sistema. Por favor contacte al administrador."
    redirect_to(request.referrer || root_path)
  end

  def user_not_authorized
    flash[:alert] = "Usted no está autorizado para realizar esta acción."
    redirect_to(request.referrer || root_path)
  end
end
