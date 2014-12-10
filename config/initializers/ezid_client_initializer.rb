Ezid::Client.configure do |config|
  config.default_shoulder = Rails.application.secrets.ezid_client_default_shoulder
  config.user = Rails.application.secrets.ezid_client_user
  config.password = Rails.application.secrets.ezid_client_password
end
