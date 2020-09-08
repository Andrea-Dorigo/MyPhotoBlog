Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

      root 'photos#index', as: 'home'

      post '/comments', to: 'photos#create_comment'

      resources :comments
end
