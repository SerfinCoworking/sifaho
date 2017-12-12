Rails.application.routes.draw do
  resources :supplies
  resources :prescriptions
  resources :patients
  resources :medications
  resources :quantity_medications
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
end
