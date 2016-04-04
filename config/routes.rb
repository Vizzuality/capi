Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get 'sectors', to: 'sectors#index'
      get 'countries', to: 'countries#index'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
