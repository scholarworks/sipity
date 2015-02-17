require 'capybara/poltergeist'

if ENV['ACCESSIBLE']
  require 'capybara/accessible'

  RSpec.configure do |config|
    config.around(:each, inaccessible: true) do |example|
      Capybara::Accessible.skip_audit { example.run }
    end
  end

  Capybara.default_driver = :accessible_poltergeist
  Capybara.javascript_driver = :accessible_poltergeist
else
  Capybara.default_driver = :rack_test
end

Capybara.ignore_hidden_elements = false
Capybara.asset_host = 'http://localhost:3000'
