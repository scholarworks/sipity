Rails.application.routes.draw do
  scope module: :sipity do
    scope module: :controllers do
      resources :works, only: [:show] do
        resources :comments, only: :index
      end

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

  get(
    'areas/:work_area_slug', as: 'work_area', to: 'sipity/controllers/work_areas#query_action', defaults: { processing_action_name: 'show' }
  )
  get 'areas/:work_area_slug/do/:processing_action_name', as: 'work_area_action', to: 'sipity/controllers/work_areas#query_action'

  [:post, :put, :patch, :delete].each do |http_verb_name|
    send(http_verb_name, 'areas/:work_area_slug/do/:processing_action_name', to: 'sipity/controllers/work_areas#command_action')
  end

  get(
    'areas/:work_area_slug/:submission_window_slug',
    as: 'submission_window',
    defaults: { processing_action_name: 'show'},
    to: 'sipity/controllers/submission_windows#query_action'
  )

  get(
    'areas/:work_area_slug/:submission_window_slug/do/:processing_action_name',
    as: 'submission_window_action',
    to: 'sipity/controllers/submission_windows#query_action'
  )

  [:post, :put, :patch, :delete].each do |http_verb_name|
    send(
      http_verb_name,
      'areas/:work_area_slug/:submission_window_slug/do/:processing_action_name',
      to: 'sipity/controllers/submission_windows#command_action'
    )
  end

  get(
    'work_submissions/:work_id',
    as: 'work_submission',
    to: 'sipity/controllers/work_submissions#query_action',
    defaults: { processing_action_name: 'show' }
  )
  get(
    'work_submissions/:work_id/do/:processing_action_name',
    as: 'work_submission_action',
    to: 'sipity/controllers/work_submissions#query_action'
  )
  [:post, :put, :patch, :delete].each do |http_verb_name|
    send(http_verb_name, 'work_submissions/:work_id/do/:processing_action_name', to: 'sipity/controllers/work_submissions#command_action')
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
