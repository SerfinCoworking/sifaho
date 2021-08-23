Rails.application.routes.draw do
  localized do
    # Recibos
    resources :receipts do
      member do
        get :delete
      end
    end
  end
end
