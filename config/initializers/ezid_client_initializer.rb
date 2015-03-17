Ezid::Client.configure do |config|
  config.default_shoulder = Figaro.env.ezid_client_default_shoulder!
  config.user = Figaro.env.ezid_client_user!
  config.password = Figaro.env.ezid_client_password!
end
