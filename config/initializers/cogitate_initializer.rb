Cogitate.configure do |config|
  config.tokenizer_password = Figaro.env.cogitate_services_tokenizer_public_password!
  config.remote_server_base_url = Figaro.env.cogitate_services_remote_server_base_url!
  config.tokenizer_encryption_type = Figaro.env.cogitate_services_tokenizer_encryption_type!
  config.tokenizer_issuer_claim = Figaro.env.cogitate_services_tokenizer_issuer_claim!
  config.after_authentication_callback_url = Figaro.env.cogitate_services_after_authentication_callback_url!
end
