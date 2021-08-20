Rails.application.routes.draw do
  localized do
    scope module: :establishments do
      resources :establishments do
        member do
          get :delete
        end
        collection do
          get :search_by_name
        end
      end

      namespace :external_orders do
        resources :applicants do
          member do
            get :dispatch_order
            get :rollback_order
            get :receive_order
          end
        end

        resources :providers do
          member do
            get :dispatch_order
            get :rollback_order
            get :accept_order
            get :nullify_order
          end
          collection do
            get 'find_lots(/:order_product_id)', to: 'providers#find_lots', as: 'find_order_product_lots'
          end
        end
      end
    end

    resources :external_orders, only: %i[show destroy] do
      collection do
        get :statistics
        # get "find_lots(/:order_product_id)", to: "external_orders#find_lots", as: "find_order_product_lots"
      end
    end

    # External order comments
    resources :external_order_comments, only: %i[show create]

    # External order templates
    resources :external_order_templates do
      collection do
        get :new_provider
      end
      member do
        get :delete
        get :edit_provider
      end
    end
  end
end
