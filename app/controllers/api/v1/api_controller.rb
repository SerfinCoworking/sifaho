module Api::V1
  class ApiController < ApplicationController
    before_action :authenticate_user!
  end
end