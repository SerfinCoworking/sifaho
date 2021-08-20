Rails.application.routes.draw do

  resources :inpatient_prescriptions do
    resources :inpatient_prescription_products do
      collection do
        patch ':id/entregar', to: 'inpatient_prescription_products#deliver_children', as: 'deliver_children'
      end
    end
    resources :in_pre_prod_lot_stocks
    resources :beds
    collection do
      get ':id/productos', to: 'inpatient_prescriptions#set_products', as: 'set_products'
      get ':id/entregar', to: 'inpatient_prescriptions#delivery', as: 'delivery'
      # get 'find_lots(/:order_product_id)", to: "inpatient_prescriptions#find_lots", as: "find_order_product_lots"
      # patch ":id/entregar", to: "inpatient_prescriptions#update_with_delivery", as: "update_with_delivery"
      get 'ingresar_paciente(/:bed_id)', to: 'beds#admit_patient', as: 'admit_patient'

      resources :beds do
        member do
          get :delete
          get :admit_patient
          get :discharge_patient
        end
      end
      resources :bedrooms

      resources :inpatient_movements, only: %i[index show new create]
    end
  end
end
