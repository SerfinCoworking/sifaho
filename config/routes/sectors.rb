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
            # get :receive_order
          end
        end

        # Despachos
        resources :providers do
          member do
            # get :dispatch_order
            # get :rollback_order
            # get :accept_order
            # get :nullify_order
          end
          collection do
            get 'find_lots(/:order_product_id)', to: 'providers#find_lots', as: 'find_order_product_lots'
          end
        end

      end
    end
    # Sectors
    resources :sectors do
      collection do
        get :with_establishment_id
      end
    end

    # resources :internal_orders, only: %i[show destroy] do
    #   member do
    #     get :return_provider_status
    #     get :receive_applicant
    #     get :edit_provider
    #     patch :send_provider
    #     get :nullify
    #     put :update_provider
    #   end
    #   collection do
    #     get :new_provider
    #     get :provider_index
    #     get :statistics
    #     get 'find_lots(/:order_product_id)', to: 'internal_orders#find_lots', as: 'find_order_product_lots'
    #     post :create_provider
    #   end
    # end

    # Internal order comments
    resources :internal_order_comments, only: %i[show create]

    # Internal order templates
    resources :internal_order_templates do
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
