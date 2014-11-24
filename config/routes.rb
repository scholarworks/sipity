Rails.application.routes.draw do
  namespace :sip do
    resources :headers do
      resource :doi do
        member do
          post :assign
          post :submit_request_for
        end
      end
    end
  end

  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  get 'start', to: redirect('/sip/headers/new'), as: 'start'
end
