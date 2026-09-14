Rails.application.routes.draw do
  # The expense list is the app's home screen.
  root "expenses#index"

  # Nested routes let a list be scoped to an account, and to a category within
  # that account. ExpensesController#index reads :account_id and :category_id
  # from either the nested path or a query string, so both forms work.
  resources :accounts do
    resources :expenses, only: [ :index, :show ]
    resources :categories do
      resources :expenses, only: [ :index ]
    end
  end

  resources :expenses
  resources :budgets
  resources :categories

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
