module Api::V1
  class InsurancesController < ApiController
    skip_before_action :verify_authenticity_token
    require 'json'
    require 'rest-client'
        
    # GET /api/v1/insurances/get_by_dni/:dni
    def get_by_dni
      dni = params[:dni]
      token = ENV['ANDES_TOKEN']
      insurances = RestClient::Request.execute(method: :get, url: 'https://app.andes.gob.ar/api/modules/obraSocial/puco/',
        timeout: 30, headers: {
          "Authorization" => "JWT #{token}",
          params: {'dni': dni}
        }
      )
      render json: insurances, status: :ok
    end
  end
end