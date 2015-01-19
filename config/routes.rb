Rails.application.routes.draw do
  scope module: :sipity do
    scope module: :controllers do
      resources :works do
        resource :citation
        resource :doi do
          member do
            post :assign_a_doi
            post :request_a_doi
          end
        end
      end
      get 'works/:work_id/describe', to: 'work_descriptions#new', as: 'describe_work'
      post 'works/:work_id/describe', to: 'work_descriptions#create'
    end
  end

  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  get 'start', to: redirect('/works/new'), as: 'start'
end
