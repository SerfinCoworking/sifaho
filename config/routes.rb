Rails.application.routes.draw do

  resources :stocks
  # Lotes
  resources :lots do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
    collection do
      get "trash_index"
      get "search_by_code"
    end
  end

  # Products
  resources :products do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
    collection do
      get "trash_index"
      get "search_by_code"
      get "search_by_name"
    end
  end

  resources :permission_requests do
    member do
      get "end"
    end
  end

  resources :internal_order_templates do
    collection do
      get "new_provider"
    end
    member do
      get "delete"
      get "use_applicant"
      get "use_provider"
      get "edit_provider"
    end
  end

  get 'report/newExternalOrder'

  post 'auth/login', to: 'authentication#authenticate'

  resources :categories

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount Notifications::Engine => "/notifications"

  # Con esta ruta marcamos una notificacion como leida
  post '/notifications/:id/set-as-read',
    to: 'notifications/notifications#set_as_read',
    as: 'notifications_set_as_read'

  # devise_for :users, :controllers => { registrations: 'registrations' }
  devise_for :users, :skip => [:registrations], :controllers => {:sessions => :sessions}

  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

  resources :users_admin, :controller => 'users', only: [:index, :update, :show] do
    member do
      get "change_sector"
      get "edit_permissions"
      put "update_permissions"
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :patients
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  resources :profiles, only: [ :edit, :update, :show ]
  resources :external_order_comments, only: [ :create ]
  # get '/profile/edit', to:'profiles#edit', as:'edit_profile'
  # patch '/profile', to: 'profiles#update'
  # Rescue errors
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  resources :bed_orders do
    member do
      get "delete"
    end
    collection do
      get "bed_map"
      get "new_bed"
      post "create_bed"
    end
  end

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
    member do
      get "delete"
    end
    collection do
      get "search_by_name"
    end
  end

  resources :sectors do
    member do
      get "delete"
    end

    collection do
      get "with_establishment_id"
    end
  end

  resources :sector_supply_lots, only: [:index, :show, :create, :destroy ] do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
      get "purge"; get "purge_confirm"
      get "archive"; get "archive_confirm"
      get "lots_for_supply"
    end
    collection do
      get "select_lot"
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
      get "nullify_confirm"
      patch "nullify"
    end
    collection do
      get "new_report"; get "generate_report"
      get "new_applicant"
      get "new_provider"
      get "applicant_index"
      get "statistics"
    end
  end

  resources :external_orders do
    member do
      get "delete"
      get "send_provider"
      get "send_applicant"
      get "return_status"
      get "accept_provider"; get "accept_provider_confirm"
      get "receive_order"; get "receive_order_confirm"
      get "edit_receipt"
      get "edit_applicant"
      get "nullify_confirm"
      patch "nullify"
    end
    collection do
      get "new_report"; get "generate_report"
      get "new_receipt"
      get "new_applicant"
      get "applicant_index"
      get "statistics"
    end
  end

  resources :external_order_comments, only: [ :show, :create]

  resources :external_order_templates do
    collection do
      get "new_provider"
    end
    member do
      get "delete"
      get "use_applicant"
      get "use_provider"
      get "edit_provider"
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
      get "return_cronic_dispensation"
    end
      collection do
      get "new_cronic"
      get "get_by_patient_id"
      get "get_cronic_prescriptions"
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
      get "get_by_dni_and_fullname"
      get "get_by_dni"
      get "get_by_fullname"
    end
  end

  resources :professionals do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
    collection do
      get "doctors"
      get "get_by_enrollment_and_fullname"
    end
  end

  namespace :charts do
    get "by_month_prescriptions"
    get "by_laboratory_lots"
    get "by_status_current_sector_supply_lots"
    get "by_month_applicant_external_orders"
    get "by_month_provider_external_orders"
    get "by_order_type_external_orders"
  end

  resources :reports, only: [:show, :index] do
    collection do
      get "new_delivered_by_order"
      post "create_delivered_by_order"

      get "new_delivered_by_establishment"
      post "create_delivered_by_establishment"
    end
  end
end
