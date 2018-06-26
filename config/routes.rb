Rails.application.routes.draw do
  resources :internal_orders
  resources :supplies
  resources :prescriptions
  get "prescription/:id", to: "prescriptions#dispense", as: "dispense_prescription"
  resources :patients
  resources :medications
  resources :quantity_medications
  resources :professionals
  resources :patients
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => { registrations: 'registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  get '/profile/edit', to:'profiles#edit', as:'edit_profile'
  patch '/profile', to: 'profiles#update'
end
