Rails.application.routes.draw do
  resources :categories
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount Notifications::Engine => "/notifications"
  # devise_for :users, :controllers => { registrations: 'registrations' }
  devise_for :users, :skip => [:registrations]
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  resources :users, only: [:index]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
  get '/profile/edit', to:'profiles#edit', as:'edit_profile'
  patch '/profile', to: 'profiles#update'
  # Rescue errors
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  resources :laboratories do
    member do
      get "delete"
    end
    collection do
      get "search_by_name"
    end
  end

  resources :supply_lots do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
      get "purge"; get "purge_confirm"
    end
    collection do
      get "trash_index"
      get "search_by_code"
      get "search_by_lot_code"
      get "search_by_name"
    end
  end

  resources :establishments do
    collection do
      get "search_by_name"
    end
  end

  resources :sectors do
    collection do
      get "with_establishment_id"
    end
  end

  resources :sector_supply_lots, only: [:index, :show, :create, :destroy ] do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
      get "purge"; get "purge_confirm"
      get "lots_for_supply"
    end
    collection do
      get "trash_index"
      get "group_by_supply"
      get "get_stock_quantity"
      get "search_by_code"
      get "search_by_name"
    end
  end

  resources :internal_orders do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
      get "send_provider"
      get "send_applicant"
      get "return_provider_status"
      get "return_applicant_status"
      get "receive_applicant"; get "receive_applicant_confirm"
      get "edit_applicant"
    end
    collection do
      get "new_applicant"
      get "new_provider"
      get "applicant_index"
    end
  end

  resources :ordering_supplies do
    member do
      get "delete"
      get "send_provider"
      get "send_applicant"
      get "return_status"
      get "accept_provider"; get "accept_provider_confirm"
      get "receive_order"; get "receive_order_confirm"
      get "edit_receipt"
      get "edit_applicant"
    end
    collection do
      get "new_receipt"
      get "new_applicant"
      get "applicant_index"
    end
  end

  get "internal_order/:id", to: "internal_orders#deliver", as: "deliver_internal_order"

  resources :supplies do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
    collection do
      get "trash_index"
      get "search_by_id"
      get "search_by_name"
    end
  end

  resources :prescriptions do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
      get "return_status"
    end
  end
  get "prescription/:id", to: "prescriptions#dispense", as: "dispense_prescription"

  resources :patients do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
    collection do
      get "search"
      get "search_by_dni"
    end
  end

  resources :professionals do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
    collection do
      get "doctors"
      get "doctors_by_enrollment"
    end
  end

  resources :patients do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
  end

  namespace :charts do
    get "by-month-prescriptions"
    get "by-laboratory-lots"
    get "by-status-current-sector-supply-lots"
    get "by-month-applicant-ordering-supplies"
    get "by-month-provider-ordering-supplies"
  end

  resources :office_supplies do
    member do
      get "delete"
    end
  end 
end
