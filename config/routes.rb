Rails.application.routes.draw do
  resources :product, only: [:show, :index] do
    resources :reviews, only: [:create, :index]
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  #get 'product/index,'
  #get 'product/show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
