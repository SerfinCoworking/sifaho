module Api::V1
  class ApiController < ApplicationController
    include Response
    include ExceptionHandler
  end
end