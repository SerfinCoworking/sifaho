Rails.application.routes.draw do
  resources :internal_orders
  get "internal_order/:id", to: "internal_orders#deliver", as: "deliver_internal_order"
  resources :supplies
  resources :prescriptions
  get "prescription/:id", to: "prescriptions#dispense", as: "dispense_prescription"
  resources :patients
  resources :medications
  resources :quantity_medications
  resources :professionals do
    collection do

      get "doctors"
    end
  end
  resources :patients
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => { registrations: 'registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  get '/profile/edit', to:'profiles#edit', as:'edit_profile'
  patch '/profile', to: 'profiles#update'
  # Rescue errors
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
end
