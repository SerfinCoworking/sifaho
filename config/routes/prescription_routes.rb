Rails.application.routes.draw do
  localized do
    scope module: :prescriptions, path: :prescriptions do
      # Outpatient
      resources :outpatient_prescriptions, except: %i[new create] do
        member do
          get :return_dispensation
          get :dispense
        end
        collection do
          get 'nueva/:patient_id', to: 'outpatient_prescriptions#new', as: 'new'
          post 'nueva/:patient_id', to: 'outpatient_prescriptions#create', as: 'create'
          get 'find_lots(/:order_product_id)', to: 'outpatient_prescriptions#find_lots', as: 'find_order_product_lots'
        end
      end

      # Chronic
      resources :chronic_prescriptions, except: %i[new create] do
        resources :chronic_dispensations, only: %i[new create] do
          get :return_dispensation_modal
          patch :return_dispensation
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

      # Inpatient
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

    get :prescriptions, to: 'prescriptions#new', as: 'new_prescription'
    # ajax para obtener recetas [cronicas / ambulatorias]
    get 'prescriptions(/:patient_id)', to: 'prescriptions#get_prescriptions', as: 'get_prescriptions'
  end
end
