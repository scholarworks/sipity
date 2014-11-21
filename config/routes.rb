Rails.application.routes.draw do
  namespace :sip do
    resources :headers do
      resource :doi
    end
  end

  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  get 'start', to: redirect('/sip/headers/new'), as: 'start'
end
