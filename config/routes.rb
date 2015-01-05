Rails.application.routes.draw do
  scope module: :sipity do
    scope module: :controllers do
      resources :sips do
        resource :citation
        resource :doi do
          member do
            post :assign_a_doi
            post :request_a_doi
          end
        end
      end
    end
  end

  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  get 'start', to: redirect('/sips/new'), as: 'start'
end
