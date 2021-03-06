Rails.application.routes.draw do
  devise_for :admins
  mount ActionCable.server => '/cable'

  root 'home#index'
  resources :messages
  resources :home, only: [:index], path: '' do
    collection do
      get 'privacy'
      get 'clear_messages'
      post 'create_subscriber'
    end
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  namespace :api do
    namespace :v1 do
      resources :registrations, only: [:create, :update] do
        collection do
          get 'check_login'
        end
      end
      resources :providers
      resources :networks, only: [:index, :create]
      resources :messages do
        collection do
          post 'lock'
          post 'unlock'
          post 'delete'
          post 'sms_sharing'
          get 'legendary_list'
          get 'profile_messages'
          get 'block'
          post 'social_feed'
        end
      end
      resources :networks_users, only: [:index]
      resources :members, only: [:create]
      resources :profiles do
        collection do
          get 'user_by_provider'
          post 'connect_social'
          post 'change_points_count'
          get 'disabled_hero'
        end
      end
      resources :sessions, only: [:create, :destroy] do
        collection do
          post 'oauth_login'
          post 'verification'
        end
      end
      resources :user_likes, only: [:create]
      resources :legendary_likes, only: [:create, :index]
      resources :invitations, only: [:create]
      resources :contacts, only: [:create]
      get '/sms', to: 'invitations#sms'
    end
  end
end
