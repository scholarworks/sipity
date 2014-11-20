Rails.application.routes.draw do
  namespace :sip do
    resources :headers
  end

  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  get 'start', to: redirect('/sip/headers/new'), as: 'start'
end
