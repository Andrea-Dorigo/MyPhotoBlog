Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'photos#index', as: 'home'

  post '/c', to: 'photos#create_comment'
  patch '/c', to: 'photos#create_comment'
  # get '/test', to: 'photos#test'
  get '/', to: 'photos#show_photo_gallery'
  post '/', to: 'photos#show_photo_gallery'
  # get '/comments/new', to: 'photos#new_comment'

  resources :comments, :tweets
end
