class ErrorsController < ApplicationController
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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
