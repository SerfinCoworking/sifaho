Rails.application.routes.draw do
  localized do
    # External orders
    scope module: :establishments, path: :establishments do
      namespace :external_orders do
        # Solicitudes
        resources :applicants do
          member do
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
            get :dispatch_order
            get :rollback_order
            get :nullify_order
            get :edit_products
            post 'edit_products', to: 'providers#accept_order', as: 'accept_order'
          end
          resources :products, except: [:index]
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
