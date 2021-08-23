Rails.application.routes.draw do

  # Custom error routes
  match '/404' => 'errors#not_found', :via => :all
  match '/406' => 'errors#not_acceptable', :via => :all
  match '/422' => 'errors#unprocessable_entity', :via => :all
  match '/500' => 'errors#internal_server_error', :via => :all

  localized do
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    root 'welcome#index'

    resources :categories

    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    mount Notifications::Engine => '/notifications'

    get 'insurances/get_by_dni(/:dni)', to: 'insurances#get_by_dni', as: :get_insurance

    resources :purchases do
      member do
        get 'set_products'
        patch 'set_products', to: 'purchases#save_products'
        get 'receive_purchase'
        get 'return_to_audit_confirm'
        patch 'return_to_audit'
      end
    end

    get 'internal_order/:id', to: 'internal_orders#deliver', as: 'deliver_internal_order'

    get 'find_lots', to: 'product_lot_stock#find_lots', as: 'find_order_product_lots'
    # ajax para guardar los lotes seleccionados
    patch 'update_lot_stock_selection/:order_product_id', to: 'product_lot_stock#update_lot_stock_selection',
                                                          as: 'update_lot_stock_selection'

    namespace :charts do
      get :by_month_prescriptions
      get :by_laboratory_lots
      get :by_status_current_sector_supply_lots
      get :by_month_applicant_external_orders
      get :by_month_provider_external_orders
      get :by_order_type_external_orders_my_orders
      get :by_order_type_external_orders_other_orders
    end

    # Sanitary zones
    resources :sanitary_zones do
      member do
        get :delete
      end
    end
  end
end
