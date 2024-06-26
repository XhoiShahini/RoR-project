# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  resources :companies
  resources :sms_verifications, only: [:new, :create]
  resources :meetings do
    resources :participants do
      resource :id_upload, controller: "participants/id_uploads", only: [:new, :create, :show, :destroy]
      resource :sign_in, controller: "participants/sign_in", only: [:create, :show, :destroy] do
        get :otp
        post :send_otp
      end
      member do
        get :verify
        get :resend_invite
      end
    end

    resources :documents do
      collection do
        get :tabs
      end

      member do
        get :pdf
        get :download
        get :merge
        get :new_signature
        get :sign
        get :cannot_sign
        get :otp
        get :otp_verified
        get :otp_failed
        get :mark_as_read
        get :signatures
        post :verify_otp
        post :xfdf
      end
    end

    resources :meeting_members, path: :members do
      member do
        get :identification
      end
    end

    resource :room, controller: "meetings/room", only: [:show, :update] do
      get :pre_meeting
      get :post_meeting
      post :perform_action
    end

    member do
      get :allow_signatures
    end
  end

  # Jumpstart views
  if Rails.env.development? || Rails.env.test?
    mount Jumpstart::Engine, at: "/jumpstart"
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Administrate
  authenticated :user, lambda { |u| u.admin? } do
    namespace :admin do
      if defined?(Sidekiq)
        require "sidekiq/web"
        mount Sidekiq::Web => "/sidekiq"
      end

      resources :announcements
      resources :users
      namespace :user do
        resources :connected_accounts
      end
      resources :accounts
      resources :account_users
      resources :plans
      namespace :pay do
        resources :charges
        resources :subscriptions
      end

      root to: "dashboard#show"
    end
  end

  # API routes
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resource :auth
      resource :me, controller: :me
      resources :accounts
      resources :users
      resources :meetings
    end
  end

  # User account
  devise_for :users,
    controllers: {
      masquerades: "jumpstart/masquerades",
      omniauth_callbacks: "users/omniauth_callbacks",
      registrations: "users/registrations"
    }

  resources :announcements, only: [:index]
  resources :api_tokens
  resources :accounts do
    member do
      patch :switch
    end

    resources :account_users, path: :members
    resources :account_invitations, path: :invitations, module: :accounts
  end
  resources :account_invitations

  # Payments
  resource :card
  resource :subscription do
    patch :info
    patch :pause
    patch :resume
  end
  resources :charges
  namespace :account do
    resource :password
  end

  resources :notifications, only: [:index, :show]
  namespace :users do
    resources :mentions, only: [:index]
  end
  namespace :user, module: :users do
    resources :connected_accounts
    resource :id_upload, only: [:new, :create, :show, :destroy]
  end

  namespace :action_text do
    resources :embeds, only: [:create], constraints: {id: /[^\/]+/} do
      collection do
        get :patterns
      end
    end
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
    get :pricing
    get :phone_input_utils
    get :processing_permission
    get :media_permission
    get :signature_permission
    get :signature_info
    get :marketing
    get :tutorials
  end

  post :sudo, to: "users/sudo#create"

  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"

  authenticated :user do
    root to: "dashboard#show", as: :user_root
  end

  # Public marketing homepage
  root to: "static#index"
end
