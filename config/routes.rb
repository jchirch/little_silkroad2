Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  
  get "/api/v1/merchants/find", to: "api/v1/merchants#find"

  get "/api/v1/merchants", to: "api/v1/merchants#index"
  post "/api/v1/merchants", to: "api/v1/merchants#create"
  get "/api/v1/merchants/:id", to: "api/v1/merchants#show"
  patch "/api/v1/merchants/:id", to: "api/v1/merchants#update"
  delete "/api/v1/merchants/:id", to: "api/v1/merchants#destroy"

  get "/api/v1/merchants/:id/customers", to: "api/v1/merchant_customers#index"
  get "/api/v1/merchants/:id/items", to: "api/v1/merchant_items#index"
  get "/api/v1/merchants/:id/invoices", to: "api/v1/merchant_invoices#index"
  
  get "/api/v1/items/find_all", to: "api/v1/items#find_all"

  get "/api/v1/items", to: "api/v1/items#index"
  post "/api/v1/items", to: "api/v1/items#create"
  get "/api/v1/items/:id", to: "api/v1/items#show"
  patch "/api/v1/items/:id", to: "api/v1/items#update"
  delete "/api/v1/items/:id", to: "api/v1/items#destroy"

  get "/api/v1/items/:id/merchant", to: "api/v1/items_merchant#index"

  get '/api/v1/merchants/:merchant_id/coupons', to: 'api/v1/coupons#index'
  get '/api/v1/merchants/:merchant_id/coupons/:id', to: 'api/v1/coupons#show'
  post '/api/v1/merchants/:merchant_id/coupons', to: 'api/v1/coupons#create'
  patch '/api/v1/merchants/:merchant_id/coupons/:id', to: 'api/v1/coupons#update'
  delete '/api/v1/merchants/:merchant_id/coupons/:id', to: 'api/v1/coupons#delete'
  
  namespace :api do
    namespace :v1 do
      resources :merchants do
        resources :invoices, only: [:index, :show]
      end
    end
  end
end