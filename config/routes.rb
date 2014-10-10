Resnate::Application.routes.draw do
  root "resnate_pages#home"
  
  get "resnate_pages/AmazonStore"
  get "/profile" => "users#profile"
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]
  get "/:id/pastGigs" => "users#pastGigs"
  get "/:id/upcomingGigs" => "users#upcomingGigs"
  get "/:id/index" => "users#index"
  get "/:id/followees" => "users#followees"
  get "/:id/followers" => "users#followers"
  get "/:id/artistLikes" => "users#artistLikes"
  get "/:id/recCount" => "users#recCount"
  get "/:id/pointCount" => "users#pointCount"
  get "/:id/:search/friendsWhoLike" => "users#friendsWhoLike"
  get "/:id/point1" => "users#point1"
  get "/:id/point5" => "users#point5"
  get "/:id/conversations" => "users#conversations"
  get "/:id/notifications" => "users#notifications"
  get "/:id/playlistFollowers" => "playlists#playlistFollowers"
  get "/:id/show" => "playlists#show"
  get "/:id/destroy" => "playlists#destroy"
  get "/:id/form" => "playlists#form"
  get "/:id/userPlaylists" => "users#userPlaylists"
  get "search" => "users#search"
  get "autocomplete" => "users#autocomplete"
  get 'follow' => 'users#follow'
  get 'unfollow' => 'users#unfollow'
  get 'playlists/follow' => 'playlists#follow'
  get 'playlists/unfollow' => 'playlists#unfollow'
  get '/:user/likes' => 'likes#show'
  get '/:user/:content/songs/show' => 'songs#show'
  get '/:user/history' => 'songs#history'
  get '/:user/:content/like' => 'songs#like'
  get '/:user/:content/unlike' => 'songs#unlike'
  get '/:user/:songkick_id/gigs/like' => 'gigs#like'
  get '/:user/:songkick_id/gigs/unlike' => 'gigs#unlike'
  get '/:user/:songkick_id/gigs/friendsGoing' => 'gigs#friendsGoing'
  get "/:songkick_id/:user/reviewForm" => "past_gigs#reviewForm"
  get "/:songkick_id/:user/reviewLike" => "past_gigs#reviewLike"
  get "/:id/reviewShow" => "past_gigs#reviewShow"
  get "/:user/:multiGigs/multipleCreate" => "past_gigs#multipleCreate"
  resources :users, :path => ''
  resources :songs, only: [:create, :destroy]
  resources :gigs, only: [:create, :destroy]
  resources :past_gigs, only: [:create, :update, :destroy]
  resources :playlists, only: [:create, :update, :destroy, :show]
  resources :messages do
    member do
      post :new
    end
  end
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
