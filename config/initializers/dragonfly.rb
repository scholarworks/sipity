require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret Figaro.env.dragonfly_secret

  url_format "/attachments/:job/:name"

  if Rails.env.test?
    datastore :memory
  else
    datastore :file,
      root_path: Rails.root.join('dragonfly', Rails.env),
      server_root: Rails.root.join('public')
  end

  before_serve do |job, env|
    user = env.fetch('warden').user
    Sipity::Services::AuthorizationLayer.without_authorization_to_attachment(file_uid: job.uid, user: user) do
      throw :halt, [401, { 'Content-Type' => 'text/plain' }, ["Unauthorized"]]
    end
  end
end

# Logger
Dragonfly.logger = Rails.logger

# Mount as middleware
Rails.application.middleware.use Dragonfly::Middleware

# Add model functionality
if defined?(ActiveRecord::Base)
  ActiveRecord::Base.extend Dragonfly::Model
  ActiveRecord::Base.extend Dragonfly::Model::Validations
end
