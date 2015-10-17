Resnate::Application.routes.draw do
  

  root "resnate_pages#home"
  
  get "resnate_pages/AmazonStore"
  get "/leaderboard" => "resnate_pages#leaderboard"
  get "/topReviews" => "resnate_pages#topReviews"
  get "/artistSearch" => "resnate_pages#artistSearch"
  get "/:id/profile" => "users#profile"
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]

  get "search" => "users#search"

  get "/:id/pastGigs" => "users#pastGigs"
  get "/:id/upcomingGigs" => "users#upcomingGigs"
  get "/:id/followees" => "users#followees"
  get "/:id/followers" => "users#followers"
  get "/:id/followeesUIDs" => "users#followeesUIDs"
  get "/:id/artistLikes" => "users#artistLikes"
  get "/:id/lastMsg" => "users#lastMsg"
  get "/:id/userActivities" => "users#userActivities"
  get "/:id/userReviews" => "users#userReviews"
  get "/points" => "users#points"
  get "/:id/:search/friendsWhoLike" => "users#friendsWhoLike"
  post "/:id/point1" => "users#point1"
  post "/:id/pointMinus1" => "users#pointMinus1"
  post "/:id/pointMinus5" => "users#pointMinus5"
  post "/:id/point5" => "users#point5"
  get "/:id/conversations" => "users#conversations"
  get "/:id/notifications" => "users#notifications"

  get "/:id/playlistFollowers" => "playlists#playlistFollowers"
  get "/newPlaylist" => "playlists#newPlaylist"
  post "/:id/:content/form" => "playlists#form"
  get "/:id/userPlaylists" => "users#userPlaylists"

  get "autocomplete" => "users#autocomplete"

  post 'follow' => 'users#follow'
  post 'unfollow' => 'users#unfollow'
  post 'playlists/follow' => 'playlists#follow'
  post 'playlists/unfollow' => 'playlists#unfollow'
  get 'playlists/:id/playlistLi' => 'playlists#playlistLi'

  get '/:user/likes' => 'likes#show'

  get '/:user/:content/songs/show' => 'songs#show'
  get '/:user/:content/songs/lastSong' => 'songs#lastSong'
  get '/:user/history' => 'songs#history'
  get '/songs/:id/reviewTemplate' => 'songs#reviewTemplate'
  post '/:user/:content/like' => 'songs#like'
  post '/:user/:content/unlike' => 'songs#unlike'

  get '/indexHeader' => 'activities#indexHeader'
  get '/peopleHeader' => 'users#peopleHeader'
  
  post '/:id/gigs/like' => 'gigs#like'
  post '/:id/gigs/unlike' => 'gigs#unlike'
  get '/:user/:songkick_id/gigs/friendsGoing' => 'gigs#friendsGoing'
  post '/gigUndo/:songkick_id' => 'gigs#gigUndo'
  
  post "/:user/multipleCreate" => "gigs#multipleCreate"

  get "/:setlistURL/setlist" => "past_gigs#setlist"
  post "/:user/pastMultipleCreate" => "past_gigs#pastMultipleCreate"
  get "/:id/writeGigReview" => "past_gigs#writeGigReview"

  post "/reviews/:id/reviewLike" => "reviews#like"
  post "/reviews/:id/reviewUnlike" => "reviews#unlike"
  get "/reviews/:id/pl" => "reviews#pl"
  
  get "/:commentable_type/:commentable_id/comments/index" => "comments#index"
  post "/:commentable_type/:commentable_id/comments/create" => "comments#create"
  post "/comments/:id/destroy" => "comments#destroy"

  resources :users, only: [:create, :update, :destroy]
  resources :songs, only: [:create, :destroy]
  resources :gigs, only: [:create, :destroy]
  resources :past_gigs, only: [:create, :update, :destroy]
  resources :playlists, only: [:create, :update, :destroy, :show]
  resources :reviews
  resources :messages do
    member do
      post :new
    end
  end

  resources :activities


  namespace :api, :defaults => {:format => :json} do
    
      resources :users, except: :destroy
      get "/userSearch/:oauth"  => "users#userSearch"
      get "search/:id/" => "users#search"
      get "/users/:id/level"  => "users#level"
      get "/users/:id/profile"  => "users#profile"
      get "/users/:id/login"  => "users#login"
      get "/users/:id/reviews"  => "users#reviews"
      get "/users/:id/past_gigs"  => "users#past_gigs"
      get "/users/:id/upcoming_gigs"  => "users#upcoming_gigs"
      get "/users/:id/playlists"  => "users#playlists"
      get "/users/:id/likes"  => "users#likes"
      get "/users/:id/followees" => "users#followees"
      get "/users/:id/followers" => "users#followers"
      get "/:id/userActivities" => "users#userActivities"

      get "/activities/:id/index" => "activities#index"
      get "/:id/activities/" => "activities#show"
      get "/:trackable_type/:trackable_id/findActivityComments" => "activities#findActivityComments"
      get "/:trackable_type/:trackable_id/findActivity" => "activities#findActivity"

      get "/:commentable_type/:commentable_id/comments/index" => "comments#index"
      get "/:commentable_type/:commentable_id/comments/count" => "comments#count"
      post "/:commentable_type/:commentable_id/comments/create" => "comments#create"
      post "/comments/:id/destroy" => "comments#destroy"

      get "/AmazonStore/:id/:search_query" => "resnate_pages#AmazonStore"

      get '/likes/:id/' => 'likes#show'
      post '/likes' => 'likes#create'
      delete '/likes' => 'likes#destroy'
      get '/likes/ifLike/:likeable_type/:liker_id/:likeable_id' => 'likes#ifLike'

      get "/past_gigs/:id/review"  => "past_gigs#review"

      resources :past_gigs

      resources :gigs

      get "/gigs/:user/:songkick_id/friendsGoing"  => "gigs#friendsGoing"

      resources :songs

      resources :reviews

      get "/reviews/:id/likes"  => "reviews#likes"

      put "/reviews/:id/updateRating/"  => "reviews#updateRating"

      resources :playlists

      resources :messages do
        member do
          post :new
        end
      end

      get "/messages/:token/index"  => "messages#index"
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
