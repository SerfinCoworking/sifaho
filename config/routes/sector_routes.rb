Rails.application.routes.draw do
  localized do
    # Internal orders
    resources :internal_orders, only: %i[show destroy] do
      member do
        get :delete
        get :return_provider_status
        get :return_applicant_status
        get :receive_applicant
        get :edit_applicant 
        get :edit_provider
        patch :send_provider
        patch :send_applicant
        get :nullify
        put :update_applicant
        put :update_provider
      end
      collection do
        get :new_applicant
        get :new_provider
        get :applicant_index
        get :provider_index
        get :statistics
        get 'find_lots(/:order_product_id)', to: 'internal_orders#find_lots', as: 'find_order_product_lots'
        post :create_applicant
        post :create_provider
      end
    end

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

    # Sectors
    resources :sectors do
      member do
        get :delete
      end

      collection do
        get :with_establishment_id
      end
    end
  end
end
