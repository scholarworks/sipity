Rails.application.routes.draw do
  namespace :sip do
    resources :headers do
      resource :doi do
        member do
          post :assign_a_doi
          post :request_a_doi
        end
      end
    end
  end

  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  get 'start', to: redirect('/sip/headers/new'), as: 'start'
end
