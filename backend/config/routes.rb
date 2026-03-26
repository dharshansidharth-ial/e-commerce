Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do

      namespace :admin do
        resources :products
        resources :orders, only: [:index, :show, :update]
        resources :reviews, only: [:index, :destroy]
        resources :users , only: [:index, :update]
      end

      namespace :seller do
        get "/dashboard", to: "dashboard#show"
        resources :products
      end


      get "/me", to: "debug#me"
      post "/auth/login", to: "auth#login"
      post "/auth/register", to: "auth#register"
      get "/users/me", to: "users#profile"
      patch "/users/me", to: "users#update"
      patch "/users/update_password", to: "users#update_password"
      delete "/users/me", to: "users#destroy"

      resources :users, only: [:index, :show, :create] do
        resources :addresses
        resources :phone_numbers
      end

      namespace :checkout do
        resources :orders do
          member do
            patch :cancel
          end

          resources :order_items
          resources :payments do
            resources :refunds
          end
        end
      end

      namespace :feedback do
        resources :reviews
      end

      namespace :catalog do
        resources :products
        resources :categories do
          resources :products, only: [:index]
        end
      end

      namespace :shopping do
        resource :cart, only: [:show, :create, :destroy] do
          resources :cart_items
        end
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
