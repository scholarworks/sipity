Rails.application.routes.draw do
  namespace :sip do
    resources :headers do
      resource :doi
    end
  end
  # I like this URL as I am putting the identifier at this location.
  put "/sip/headers/:header_id/doi", to: 'sip/dois#assign', as: 'assign_sip_header_doi'

  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  get 'start', to: redirect('/sip/headers/new'), as: 'start'
end
