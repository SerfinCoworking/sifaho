module Api::V1
  class ApiController < ApplicationController
    skip_before_action :authenticate_user!
  end
end