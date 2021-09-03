Rails.application.routes.draw do
  localized do
    # External orders
    scope module: :establishments, path: :establishments do
      namespace :external_orders do
        # Solicitudes
        resources :applicants do
          member do
            get :dispatch_order
            get :rollback_order
            get :receive_order
            get :edit_products
          end
          resources :products, except: [:index]
        end
        
        # Despachos
        resources :providers do
          member do
            get :dispatch_order
            get :rollback_order
            get :accept_order
            get :nullify_order
            get :edit_products
          end

          collection do
            get 'find_lots(/:order_product_id)', to: 'providers#find_lots', as: 'find_order_product_lots'
          end

          resources :products, except: [:index]
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

    # Establishments
    resources :establishments do
      member do
        get :delete
      end
      collection do
        get :search_by_name
      end
    end
  end
end
