class ErrorsController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  before_action :authenticate_user!

  def user_not_authorized
    flash[:error] = "Usted no está autorizado para realizar esta acción."
    redirect_to(request.referrer || root_path)
  end

  def internal_server_error
    render(:status => 500)
  end

  def not_found
    render(:status => 404)
  end

  def unprocessable_entity
    render(:status => 422)
  end

  def not_acceptable
    render(:status => 406)
  end
end
