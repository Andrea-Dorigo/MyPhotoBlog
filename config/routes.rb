Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'photos#index', as: 'home'

  post '/', to: 'photos#create_comment'
  patch '/', to: 'photos#create_comment'
  # get '/test', to: 'photos#test'
  get '/show_photo_gallery', to: 'photos#show_photo_gallery'
  # get '/comments/new', to: 'photos#new_comment'

  resources :comments
end
