Rails.application.routes.draw do
  get 'recetas', to: 'prescriptions#new', as: 'new_prescription'
  get 'prescriptions(/:patient_id)', to: 'prescriptions#get_prescriptions', as: 'get_prescriptions' #ajax para obtener recetas [cronicas / ambulatorias]

  # en row_id debemos agregar el id de OutpatientPrescriptionProduct
  resources :outpatient_prescriptions, except: %i[new create] do
    member do
      get 'return_dispensation'
      get 'dispense'
    end
    collection do
      get 'nueva/:patient_id', to: 'outpatient_prescriptions#new', as: 'new'
      post 'nueva/:patient_id', to: 'outpatient_prescriptions#create', as: 'create'
      get 'find_lots(/:order_product_id)', to: 'outpatient_prescriptions#find_lots', as: 'find_order_product_lots'
    end
  end

  resources :chronic_prescriptions, except: %i[new create] do
    resources :chronic_dispensations, only: %i[new create] do
      get 'return_dispensation_modal'
      patch 'return_dispensation'
    end

    member do
      get :finish
      get 'finish_treatment/:original_product_id', to: 'original_chronic_prescription_products#finish_treatment', as: 'finish_treatment'
      patch 'update_treatment/:original_product_id', to: 'original_chronic_prescription_products#update_treatment', as: 'update_treatment'
    end

    collection do
      get 'nueva/:patient_id', to: 'chronic_prescriptions#new', as: 'new'
      post 'nueva/:patient_id', to: 'chronic_prescriptions#create', as: 'create'
      get 'find_lots(/:order_product_id)', to: 'chronic_dispensations#find_lots', as: 'find_order_product_lots'
    end
  end
end
