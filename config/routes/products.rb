Rails.application.routes.draw do
  # Products
  resources :products do
    member do
      get :delete
      get :restore
      get :restore_confirm
    end
    collection do
      get :trash_index
      get :search_by_code
      get :search_by_name
      get :search_by_name_to_order
      get :search_by_code_to_order
    end
  end

  # Areas
  resources :areas do
    member do
      get :fill_products_card
    end
    collection do
      get :tree_view
    end
  end

  # Snomed concepts
  resources :snomed_concepts, except: %i[edit update] do
    member do
      get :delete
    end

    collection do
      get :find_new
      get :search
    end
  end
end