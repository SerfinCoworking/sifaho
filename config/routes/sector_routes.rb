Rails.application.routes.draw do
  localized do
    # Sectors
    scope module: :sectors, path: :sectors do
      namespace :internal_orders do
        # Solicitudes
        resources :applicants do
          member do
            get :dispatch_order
            get :rollback_order
            get :receive_order
            get :set_products
          end
        end

        # Despachos
        resources :providers do
          member do
            get :dispatch_order
            get :rollback_order
            get :nullify_order
          end
          collection do
            get 'find_lots(/:order_product_id)', to: 'providers#find_lots', as: 'find_order_product_lots'
          end
        end

        # Plantillas
        namespace :templates do
          get '', to: 'templates#index'
          # Solicitudes
          resources :applicants
          # Despachos
          resources :providers
        end

        # Comments
        resources :comments, only: %i[show create]
      end
    end
    # Sectors
    resources :sectors do
      collection do
        get :with_establishment_id
      end
    end
  end
end
