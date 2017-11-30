Rails.application.routes.draw do
  get 'prescription_statuses/new'

  get 'prescription_statuses/create'

  get 'prescription_statuses/edit'

  get 'prescription_statuses/destroy'

  get 'order_statuses/new'

  get 'order_statuses/create'

  get 'order_statuses/edit'

  get 'order_statuses/destroy'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'
end
