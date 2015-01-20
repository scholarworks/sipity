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

      # TODO: There is the concept of valid enrichments; extract those
      enrichment_constraint = lambda do |request|
        enrichment_type = request.params.fetch(:enrichment_type)
        # REVIEW: Magic strings! There is a canonical enrichment question; And
        #   the valid enrichments may not be available for all work ids
        %(attach describe).include?(enrichment_type)
      end
      get 'works/:work_id/:enrichment_type', to: 'work_enrichments#edit', as: 'enrich_work', constraints: enrichment_constraint
      post 'works/:work_id/:enrichment_type', to: 'work_enrichments#update', constraints: enrichment_constraint
    end
  end

  mount Upmin::Engine => '/admin'
  root to: 'visitors#index'
  devise_for :users
  get 'start', to: redirect('/works/new'), as: 'start'
end
