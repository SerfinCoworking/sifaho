Rails.application.routes.draw do
  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :patients
      post 'authenticate', to: 'authentication#authenticate'
      # get 'insurances/get_by_dni(/:dni)', to: 'insurances#get_by_dni', :as => "get_insurance"
    end
  end
end
