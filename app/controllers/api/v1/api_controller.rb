module Api::V1
  class ApiController < ApplicationController
    protect_from_forgery with: :exception
    before_action :authenticate_user!
  end
end