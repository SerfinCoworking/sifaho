Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users, :controllers => { registrations: 'registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  get '/profile/edit', to:'profiles#edit', as:'edit_profile'
  patch '/profile', to: 'profiles#update'
  # Rescue errors
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  resources :supply_lots do
    member do
      get "delete"
    end
  end

  resources :internal_orders do
    member do
      get "delete"
    end
  end
  get "internal_order/:id", to: "internal_orders#deliver", as: "deliver_internal_order"

  resources :supplies do
    member do
      get "delete"
    end
    collection do
      get "search_by_id"
      get "search_by_name"
    end
  end

  resources :prescriptions do
    member do
      get "delete"
    end
  end
  get "prescription/:id", to: "prescriptions#dispense", as: "dispense_prescription"

  resources :patients do
    member do
      get "delete"
    end
    collection do
      get "search"
    end
  end

  resources :professionals do
    member do
      get "delete"
    end
    collection do
      get "doctors"
    end
  end

  resources :patients do
    member do
      get "delete"
    end
  end
end
