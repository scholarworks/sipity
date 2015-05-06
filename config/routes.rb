Rails.application.routes.draw do
  scope module: :sipity do
    scope module: :controllers do
      resources :works do
        resource :doi do
          member do
            post :assign_a_doi
            post :request_a_doi
          end
        end
        resources :comments, only: :index
      end

      # TODO: There is the concept of valid enrichments; extract those
      enrichment_constraint = lambda do |request|
        enrichment_type = request.params.fetch(:enrichment_type)
        # REVIEW: Magic strings! There is a canonical enrichment question; And
        #   the valid enrichments may not be available for all work ids
        %(attach describe collaborators defense_date degree access_policy search_terms).include?(enrichment_type)
      end
      get 'works/:work_id/:enrichment_type', to: 'work_enrichments#edit', as: 'enrich_work', constraints: enrichment_constraint
      post 'works/:work_id/:enrichment_type', to: 'work_enrichments#update', constraints: enrichment_constraint

      # HACK: This is a shim to account for the policy behavior. I can look
      #   towards future normalization.
      get 'works/:work_id/assign_a_doi', to: 'dois#show'

      get 'works/:id/trigger/update', to: 'works#edit'
      get 'works/:id/trigger/show', to: 'works#show'

      # # Are there constraints?
      get 'works/:work_id/trigger/:processing_action_name', to: 'work_event_triggers#new', as: 'event_trigger_for_work'
      post 'works/:work_id/trigger/:processing_action_name', to: 'work_event_triggers#create'

      #Account profile Managament
      get 'account', to: 'account_profiles#edit', as: 'account'
      post 'account', to: 'account_profiles#update'
    end
  end

  root to: 'visitors#index'

  devise_for :users #, only: :sessions
  devise_for :user_for_profile_managements, class_name: 'User', only: :sessions
  get 'dashboard', to: 'sipity/controllers/dashboards#index', as: "dashboard"
  get 'start', to: redirect('/works/new'), as: 'start'


  get 'areas/:work_area_slug', as: 'work_area', to: 'sipity/controllers/work_areas#show'
  get 'areas/:work_area_slug/do/:query_action_name', as: 'work_area_query_action', to: 'sipity/controllers/work_areas#query_action'

  [:post, :put, :patch, :delete].each do |http_verb_name|
    send(http_verb_name, 'areas/:work_area_slug/do/:command_action_name', to: 'sipity/controllers/work_areas#command_action')
  end

  get(
    'areas/:work_area_slug/:submission_window_slug',
    as: 'submission_window_for_work_area',
    to: 'sipity/controllers/submission_windows#show'
  )

  get(
    'areas/:work_area_slug/:submission_window_slug/do/:query_action_name',
    as: 'submission_window_query_action',
    to: 'sipity/controllers/submission_windows#query_action'
  )

  [:post, :put, :patch, :delete].each do |http_verb_name|
    send(
      http_verb_name,
      'areas/:work_area_slug/:submission_window_slug/do/:command_action_name',
      to: 'sipity/controllers/submission_windows#command_action'
    )
  end

  # I need parentheses or `{ }` for the block, because of when the blocks are
  # bound.
  get(
    "extname_thumbnails/:width/:height/:text(.:format)" => Dragonfly.app.endpoint do |params, app|
      height = params[:height].to_i
      app.generate(:text, params[:text], 'font-size' => (height / 4 * 3), 'padding' => "#{(height - (height / 4 * 3)) / 2} 8").
        thumb("#{height}x#{params[:width]}#", 'format' => params['format'] )
    end
  )
end
