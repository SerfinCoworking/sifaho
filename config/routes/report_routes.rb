Rails.application.routes.draw do
  # Reports
  localized do
    namespace :reports do

      # Internal order product report
      resources :internal_order_product_reports,
                only: %i[show new create],
                controller: :internal_order_products,
                model: :internal_order_prodcut_reports

      # External order product report
      resources :external_order_product_reports,
                only: %i[show new create],
                controller: :external_order_products,
                model: :external_order_prodcut_reports

      # Stock quantity report
      resources :stock_quantity_reports,
                only: %i[show new create],
                controller: :stock_quantity_reports,
                model: :stock_quantity_reports

      # Monthly consumption report
      resources :monthly_consumption_reports,
                only: %i[show new create],
                controller: :monthly_consumption_reports,
                model: :monthly_consumption_reports

      # Patient product report 
      resources :patient_product_reports,
                only: %i[show new create],
                controller: :patient_product_reports,
                model: :patient_product_reports

      resources :index_reports, only: [:index]

      resources :reports, only: %i[show index]
    end


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
