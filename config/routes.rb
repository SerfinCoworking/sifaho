Rails.application.routes.draw do

  resources :receipts do
    member do
      get "delete"
    end
  end
  
  resources :stocks do
    member do
      resources :stock_movements, only: :index, path: :movimientos
    end
    collection do
      get "find_lots"
    end
  end
  # custom error routes
  match '/404' => 'errors#not_found', :via => :all
  match '/406' => 'errors#not_acceptable', :via => :all
  match '/422' => 'errors#unprocessable_entity', :via => :all
  match '/500' => 'errors#internal_server_error', :via => :all
  
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
      get "search_by_name_to_order"
      get "search_by_code_to_order"
    end
  end

  # Areas
  resources :areas do
    member do
      get :fill_products_card
    end
  end

  resources :permission_requests do
    member do
      get "end"
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
      get 'insurances/get_by_dni(/:dni)', to: 'insurances#get_by_dni', :as => "get_insurance"
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  resources :profiles, only: [ :edit, :update, :show ]

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
  
  resources :purchases do 
    member do
      get "set_products"
      patch "set_products", to: "purchases#save_products"
      get "receive_purchase"
      get "return_to_audit_confirm"
      patch "return_to_audit"
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

  resources :internal_orders, only: [:show, :destroy] do
    member do
      get "delete"
      get "send_provider"
      get "send_applicant"
      get "return_provider_status"
      get "return_applicant_status"
      get "receive_applicant"
      get "edit_applicant"
      get "edit_provider"
      get "nullify"
      patch "update_applicant"
      patch "update_provider"
    end
    collection do
      get "new_applicant"
      get "new_provider"
      get "applicant_index"
      get "provider_index"
      get "statistics"
      post "create_applicant"
      post "create_provider"
    end
  end

  resources :internal_order_comments, only: [ :show, :create]

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

  resources :external_orders, only: [:show, :destroy] do
    member do
      get "delete"
      get "send_provider"
      get "send_applicant"
      get "return_provider_status"
      get "return_applicant_status"
      get "accept_provider"
      get "receive_applicant"
      get "edit_applicant"
      get "edit_provider"
      get "nullify"
      patch "update_applicant"
      patch "update_provider"
    end
    collection do
      get "new_applicant"
      get "new_provider"
      get "applicant_index"
      get "provider_index"
      get "statistics"
      post "create_applicant"
      post "create_provider"
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

  resources :outpatient_prescriptions do
    member do
      get 'return_dispensation'
      get 'dispense'
    end
  end
  
  resources :chronic_prescriptions do 
    resources :chronic_dispensations, only: [:new, :create] do
      get 'return_dispensation_modal'
      patch 'return_dispensation'
    end
  end
  
    
  resources :prescriptions do
    member do
      get 'delete'
      get 'restore'; get 'restore_confirm'
      get 'confirm_return_ambulatory'
      patch 'return_ambulatory_dispensation'
      get 'confirm_return_cronic'
    end
    collection do
      get 'new_cronic'
      get 'get_by_patient_id'
      get 'get_cronic_prescriptions'
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
    get "by_order_type_external_orders_my_orders"
    get "by_order_type_external_orders_other_orders"
  end

  resources :reports, only: [:show, :index] do
    collection do
      get "new_delivered_by_order"
      post "create_delivered_by_order"

      get "new_delivered_by_establishment"
      post "create_delivered_by_establishment"
    end
  end

  # Routes for reports
  namespace :reports do
    resources :patient_product_reports, only: [:new] do
      collection do
        get "generate"
      end
    end
  end

  # Reports
  namespace :reports, path: 'reportes' do
    resources :index_reports, only: [:index], path: '/'

    resources :internal_order_product_reports,
      only: [:show], 
      controller: 'internal_order_products',
      model: 'internal_order_prodcut_reports',
      path: 'producto_por_sectores' do
      collection do
        get :new, path: :nuevo
        post :create, path: :crear
      end
    end

    resources :external_order_product_reports,
      only: [:show],
      controller: 'external_order_products',
      model: 'external_order_prodcut_reports',
      path: 'producto_por_establecimientos' do
      collection do
        get :new, path: :nuevo
        post :create, path: :crear
      end
    end

    resources :stock_quantity_reports,
      only: [:show],
      controller: 'stock_quantity_reports',
      model: 'stock_quantity_reports',
      path: 'stock_por_rubros' do
      collection do
        get :new, path: :nuevo
        post :create, path: :crear
      end
    end
  end
end
