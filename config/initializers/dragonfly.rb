require 'dragonfly'

# Configure
Dragonfly.app.configure do
  plugin :imagemagick

  secret Figaro.env.dragonfly_secret

  url_format "/attachments/:job/:name"

  if Rails.env.test?
    datastore :memory
  elsif Rails.env.development?
    datastore :file,
      root_path: Rails.root.join('dragonfly', Rails.env),
      server_root: Rails.root.join('public')
  else
    require 'dragonfly/s3_data_store'
    datastore :s3,
      bucket_name: Figaro.env.dragonfly_s3_bucket_name!,
      access_key_id: Figaro.env.dragonfly_s3_access_key_id!,
      secret_access_key: Figaro.env.dragonfly_s3_secret_access_key!,
      root_path: Figaro.env.dragonfly_s3_root_path!,
      path: Figaro.env.dragonfly_s3_path!,
      url_host: Figaro.env.dragonfly_s3_url_host!
  end

  before_serve do |job, env|
    user = env.fetch('warden').user
    Sipity::Services::AuthorizationLayer.without_authorization_to_attachment(file_uid: job.uid, user: user) do
      throw :halt, [401, { 'Content-Type' => 'text/plain' }, ["Unauthorized"]]
    end
  end

  response_header 'Cache-Control', 'private, max-age=10800'
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
