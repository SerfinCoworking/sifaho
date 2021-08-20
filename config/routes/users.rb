Rails.application.routes.draw do
  # devise_for :users, :controllers => { registrations: 'registrations' }
  devise_for :users, skip: [:registrations], controllers: { sessions: :sessions }

  as :user do
    get 'users/edit', to: 'devise/registrations#edit', as: 'edit_user_registration'
    put 'users', to: 'devise/registrations#update', as: 'user_registration'
  end

  resources :permission_requests do
    member do
      get :end
    end
  end

  # Con esta ruta marcamos una notificacion como leida
  post '/notifications/:id/set-as-read', to: 'notifications/notifications#set_as_read', as: 'notifications_set_as_read'

  # Users
  resources :users_admin, controller: :users, only: %i[index update show] do
    member do
      get :change_sector
      get :edit_permissions
      put :update_permissions
    end
  end

  # Profiles
  resources :profiles, only: %i[edit update show]
end
