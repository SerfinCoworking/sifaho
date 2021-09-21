Rails.application.routes.draw do
  localized do
    # Sectors
    scope module: :sectors, path: :sectors do
      namespace :internal_orders do
        # Solicitudes
        resources :applicants do
          member do
            # get :dispatch_order
            get :rollback_order
            get :receive_order
            get :edit_products
            post 'edit_products', to: 'applicants#dispatch_order', as: 'dispatch_order'
          end
          resources :products, except: [:index]
        end

        # Despachos
        resources :providers do
          member do
            get :nullify_order
            get :edit_products
            post 'edit_products', to: 'providers#dispatch_order', as: 'dispatch_order'
          end
          resources :products, except: [:index]
          collection do
            get 'find_lots(/:order_product_id)', to: 'providers#find_lots', as: 'find_order_product_lots'
          end
        end

        # Plantillas
        namespace :templates do
          get '', to: 'templates#index'
          # Solicitudes
          resources :applicants do
            member do
              post :build_from_template
            end
          end
          # Despachos
          resources :providers do
            member do
              post :build_from_template
            end
          end
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
