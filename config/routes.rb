Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  root "items#index"

  resources :items, only: [ :index, :show ] do
    resources :comments, only: [ :create ]
    resources :subscriptions, only: [ :create, :destroy ]
  end

  namespace :admin do
    resources :items, only: [ :index ] do
      collection do
        post :scan
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
