Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    unlocks: "users/unlocks"
  }

  root "communities#index"

  resources :communities, only: [ :index ]

  scope "/p/:packlight_id", as: "packlight" do
    get "/", to: "packlight_pages#show", as: "page"
    get "/items/:id", to: "packlight_pages#item", as: "item"

    resources :items, only: [] do
      resources :comments, only: [ :create ]
      resource :subscription, only: [ :create, :destroy ]
    end
  end

  namespace :admin do
    get "google_drive/connect", to: "google_drive_connections#connect", as: :google_drive_connect
    get "google_drive/callback", to: "google_drive_connections#callback", as: :google_drive_callback
    resources :items, only: [ :index, :new, :create, :edit, :update, :destroy ] do
      collection do
        post :scan
      end
      member do
        patch :mark_sold
        patch :mark_reviewed
      end
    end
    resources :packlight_accesses, only: [ :create, :destroy ]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
