Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'photos#index', as: 'home'

  # post '/', to: 'photos#create_comment'
  # patch '/', to: 'photos#create_comment'
  # # get '/test', to: 'photos#test'
  # get '/', to: 'photos#show_photo_gallery'
  post '/', to: 'photos#show_photo_gallery'
  # get '/comments/new', to: 'photos#new_comment'

  resource :photos do

    post 'create_comment', on: :member
  end
end
