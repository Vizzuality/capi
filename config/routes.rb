Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'sectors', to: 'sectors#index'
      get 'countries', to: 'countries#index'
      get 'statistics', to: 'statistics#index'
      get 'layers', to: 'layers#index'
      resources :donations, only: [:create, :index, :show] do
        collection do
          get :distribution
        end
      end
      get 'projects', to: 'projects#index'
      get 'projects/refugees', to: 'refugees#index'
      get 'projects_layer', to: 'projects_layer#index'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
