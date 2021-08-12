Rails.application.routes.draw do

  resources :stocks do
    collection do
      get '/lotes', to: 'lot_stocks#index', as: :lot_stocks_index
    end
    get '/lotes', to: 'lot_stocks#lot_stocks_by_stock', as: :lot_stocks_by_stock
    get '/lotes/:lot_stock_id/', to: 'lot_stocks#show', as: :show_lot_stocks
    get '/lotes/:lot_stock_id/new_archive', to: 'lot_stocks#new_archive', as: :new_archive
    post '/lotes/:lot_stock_id/create_archive', to: 'lot_stocks#create_archive', as: :create_archive
    
    member do
      resources :stock_movements, only: :index, path: :movimientos
    end
  end
  
  get ':id/return_archive_modal', to: 'lot_stocks#return_archive_modal', as: :return_archive_modal
  get 'lot_archive/:id', to: 'lot_stocks#show_lot_archive', as: :lot_archive
  patch ':id/return_archive', to: 'lot_stocks#return_archive', as: :return_archive

  # custom error routes
  match '/404' => 'errors#not_found', :via => :all
  match '/406' => 'errors#not_acceptable', :via => :all
  match '/422' => 'errors#unprocessable_entity', :via => :all
  match '/500' => 'errors#internal_server_error', :via => :all
  
  # Recibos
  resources :receipts, path: :recibos do
    member do
      get "delete"
    end
  end

  # Lotes
  resources :lots, path: :lotes_provincia do
    member do
      get "delete"
    end
    collection do
      get "search_by_code"
      resources :lot_provenances, path: :procedencias
    end
  end

  # Products
  resources :products, path: :productos do
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
  resources :areas, path: :rubros do
    member do
      get :fill_products_card
    end
    collection do
      get :tree_view
    end
  end

  resources :permission_requests, path: :solicitudes_permisos do
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

  resources :users_admin, path: :usuarios, :controller => 'users', only: [:index, :update, :show] do
    member do
      get "change_sector"
      get "edit_permissions"
      put "update_permissions"
    end
  end

  namespace :api, defaults: { format: 'json' } do
    namespace :v1 do
      resources :patients
      # get 'insurances/get_by_dni(/:dni)', to: 'insurances#get_by_dni', :as => "get_insurance"
    end
  end
  
  get 'insurances/get_by_dni(/:dni)', to: 'insurances#get_by_dni', :as => "get_insurance"

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  resources :profiles, path: :perfiles, only: [ :edit, :update, :show ]

  resources :laboratories, path: :laboratorios do
    collection do
      get "search_by_name"
    end
  end

  scope module: :establishments, path: 'establecimientos' do
    resources :establishments, path: '/' do
      member do
        get "delete"
      end
      collection do
        get "search_by_name"
      end
    end

    namespace :external_orders, path: 'pedidos' do
      resources :applicants
    end
  end
  
  resources :purchases, path: :abastecimientos do 
    member do
      get "set_products"
      patch "set_products", to: "purchases#save_products"
      get "receive_purchase"
      get "return_to_audit_confirm"
      patch "return_to_audit"
    end
  end

  resources :sectors, path: :sectores do
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

  resources :internal_orders, path: :pedidos_sectores, only: [:show, :destroy] do
    member do
      get "delete"
      get "return_provider_status"
      get "return_applicant_status"
      get "receive_applicant"
      get :edit_applicant, path: :editar_solicitante 
      get :edit_provider, path: :editar_proveedor
      patch :send_provider, path: :editar_proveedor
      patch :send_applicant, :editar_solicitante 
      get "nullify"
      put :update_applicant, :editar_solicitante 
      put :update_provider, path: :editar_proveedor
    end
    collection do
      get :new_applicant, path: :solicitar
      get :new_provider, path: :entregar
      get :applicant_index, path: :recibos
      get :provider_index, path: :entregas
      get :statistics, path: :estadisticas
      get "find_lots(/:order_product_id)", to: "internal_orders#find_lots", as: "find_order_product_lots"
      post :create_applicant, path: :solicitar
      post :create_provider, path: :entregar
    end

  end

  resources :internal_order_comments, only: [ :show, :create]

  resources :internal_order_templates, path: :plantillas_pedidos_sectores do
    collection do
      get "new_provider"
    end
    member do
      get "delete"
      get "edit_provider"
    end
  end

  resources :external_orders, path: :pedidos_establecimientos, only: [:show, :destroy] do
    member do
      get "delete"
      get "send_provider"
      # get "send_applicant"
      get "return_provider_status"
      # get "return_applicant_status"
      get "accept_provider"
      # get "receive_applicant"
      # get :edit_applicant, path: :editar_solicitante
      get :edit_provider, path: :editar_proveedor
      get "nullify"
      # patch "update_applicant"
      patch "update_provider"
    end
    collection do
      # get :new_applicant, path: :solicitar
      get :new_provider, path: :despachar
      # get :applicant_index, path: :recibos
      get :provider_index, path: :despachos
      get :statistics, path: :estadisticas
      get "find_lots(/:order_product_id)", to: "external_orders#find_lots", as: "find_order_product_lots"
      # post "create_applicant"
      post "create_provider"
    end
  end

  resources :external_order_comments, only: [ :show, :create]

  resources :external_order_templates, path: :plantillas_pedidos_establecimientos do
    collection do
      get "new_provider"
    end
    member do
      get "delete"
      get "edit_provider"
    end
  end

  get "internal_order/:id", to: "internal_orders#deliver", as: "deliver_internal_order"

  # en row_id debemos agregar el id de OutpatientPrescriptionProduct
  resources :outpatient_prescriptions, except: [:new, :create], path: :recetas_ambulatorias do
    member do
      get 'return_dispensation'
      get 'dispense'
    end
    collection do
      get "nueva/:patient_id", to: "outpatient_prescriptions#new", as: "new"
      post "nueva/:patient_id", to: "outpatient_prescriptions#create", as: "create"
      get "find_lots(/:order_product_id)", to: "outpatient_prescriptions#find_lots", as: "find_order_product_lots"
    end
  end
  
  resources :chronic_prescriptions, except: [:new, :create], path: :recetas_cronicas do 
    resources :chronic_dispensations, only: [:new, :create] do
      get 'return_dispensation_modal'
      patch 'return_dispensation'
    end

    member do
      get :finish
      get 'finish_treatment/:original_product_id', to: 'original_chronic_prescription_products#finish_treatment', as: 'finish_treatment'
      patch 'update_treatment/:original_product_id', to: 'original_chronic_prescription_products#update_treatment', as: 'update_treatment'
    end
    
    collection do
      get "nueva/:patient_id", to: "chronic_prescriptions#new", as: "new"
      post "nueva/:patient_id", to: "chronic_prescriptions#create", as: "create"
      get "find_lots(/:order_product_id)", to: "chronic_dispensations#find_lots", as: "find_order_product_lots"
    end
  end
  
  resources :inpatient_prescriptions, path: :internacion do
    resources :inpatient_prescription_products do
      collection do
        patch ":id/entregar", to: "inpatient_prescription_products#deliver_children", as: "deliver_children"
      end
    end
    resources :in_pre_prod_lot_stocks
    resources :beds, path: :camas
    collection do
      get ":id/productos", to: "inpatient_prescriptions#set_products", as: "set_products"
      get ":id/entregar", to: "inpatient_prescriptions#delivery", as: "delivery"
      # get "find_lots(/:order_product_id)", to: "inpatient_prescriptions#find_lots", as: "find_order_product_lots"
      # patch ":id/entregar", to: "inpatient_prescriptions#update_with_delivery", as: "update_with_delivery"
      get "ingresar_paciente(/:bed_id)", to: 'beds#admit_patient', as: 'admit_patient'
      
      resources :beds, path: :camas do
        member do
          get :delete
          get :admit_patient
          get :discharge_patient
        end
      end
      resources :bedrooms, path: :habitaciones

      resources :inpatient_movements, path: :movimientos, only: [:index, :show, :new, :create]
    end
  end
  
  
  get "find_lots", to: "product_lot_stock#find_lots", as: "find_order_product_lots"
  patch "update_lot_stock_selection/:order_product_id", to: "product_lot_stock#update_lot_stock_selection", as: "update_lot_stock_selection" #ajax para guardar los lotes seleccionados
  
  get "recetas", to: "prescriptions#new", as: "new_prescription"
  get "prescriptions(/:patient_id)", to: "prescriptions#get_prescriptions", as: "get_prescriptions" #ajax para obtener recetas [cronicas / ambulatorias]

  resources :patients, path: :pacientes do
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

  resources :professionals, path: :medicos do
    member do
      get "delete"
      get "restore"; get "restore_confirm"
    end
    collection do
      get "doctors"
      get "get_by_enrollment_and_fullname"
      get "get_by_unsigned_enrollment_fullname"
      post "asign_user"
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

    resources :monthly_consumption_reports,
      only: [:show],
      controller: 'monthly_consumption_reports',
      model: 'monthly_consumption_reports',
      path: 'consumo_por_mes' do
      collection do
        get :new, path: :nuevo
        post :create, path: :crear
      end
    end

    resources :patient_product_reports,
      only: [:show],
      controller: 'patient_product_reports',
      model: 'patient_product_reports',
      path: 'entregado_por_paciente' do
      collection do
        get :new, path: :nuevo
        post :create, path: :crear
      end
    end
  end

  # State reports
  namespace :state_reports, path: 'reportes_provincia' do
    resources :patient_product_state_reports,
      only: [:show], 
      controller: 'patient_product_state_reports',
      model: 'patient_product_state_report',
      path: 'entrega_por_paciente' do
      collection do
        get :new, path: :nuevo
        get :load_more, path: :mostrar_mas
        post :create, path: :crear
      end
    end
  end

  # Sanitary zones
  resources :sanitary_zones, path: 'zonas_sanitarias' do
    member do
      get :delete
    end
  end

  resources :snomed_concepts, except: %i[edit update], path: 'snomed' do
    member do
      get :delete
    end

    collection do
      get :find_new
      get :search
    end
  end
end
