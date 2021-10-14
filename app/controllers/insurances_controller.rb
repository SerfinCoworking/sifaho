class InsurancesController < ApplicationController

  # GET /insurances
  # GET /insurances.json
  def get_by_dni
    dni = params[:dni]
    token = ENV['ANDES_TOKEN']
    andes_puco_url = ENV['ANDES_PUCO_URL']
    @insurances = JSON.parse(RestClient::Request.execute(method: :get, url: andes_puco_url,
      verify_ssl: false,
      timeout: 30, headers: {
        "Authorization" => "JWT #{token}",
        params: { 'dni': dni }
      }
    ))
  end
end
