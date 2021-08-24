Rails.application.routes.draw do
  # Reports
  localized do
    namespace :reports do
      resources :index_reports, only: [:index]

      resources :internal_order_product_reports,
                only: [:show],
                controller: :internal_order_products,
                model: :internal_order_prodcut_reports do
        collection do
          get :new
          post :create
        end
      end

      resources :external_order_product_reports,
                only: [:show],
                controller: :external_order_products,
                model: :external_order_prodcut_reports do
        collection do
          get :new
          post :create
        end
      end

      resources :stock_quantity_reports,
                only: [:show],
                controller: :stock_quantity_reports,
                model: :stock_quantity_reports do
        collection do
          get :new
          post :create
        end
      end

      resources :monthly_consumption_reports,
                only: [:show],
                controller: :monthly_consumption_reports,
                model: :monthly_consumption_reports do
        collection do
          get :new
          post :create
        end
      end

      resources :patient_product_reports,
                only: [:show],
                controller: :patient_product_reports,
                model: :patient_product_reports do
        collection do
          get :new
          post :create
        end
      end
    end

    resources :reports, only: %i[show index]

    # State reports
    namespace :state_reports do
      resources :patient_product_state_reports,
                only: [:show],
                controller: :patient_product_state_reports,
                model: :patient_product_state_report do
        collection do
          get :new
          get :load_more
          post :create
        end
      end
    end
  end
end
