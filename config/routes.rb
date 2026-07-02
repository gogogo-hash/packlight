Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }

  root "communities#index"

  resources :communities, only: [ :index ]
  resources :items, only: [ :show ] do
    resources :comments, only: [ :create ]
    resources :subscriptions, only: [ :create, :destroy ]
  end

  scope "/p/:packlight_id", as: "packlight" do
    get "/", to: "packlight_pages#show", as: "page"
    get "/items/:id", to: "packlight_pages#item", as: "item"
  end

  namespace :admin do
    get "google_drive/connect", to: "google_drive_connections#connect", as: :google_drive_connect
    get "google_drive/callback", to: "google_drive_connections#callback", as: :google_drive_callback
    resources :items, only: [ :index, :edit, :update ] do
      collection do
        post :scan
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
