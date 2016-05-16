require 'capybara/poltergeist'

Capybara.default_driver = :rack_test

Capybara.ignore_hidden_elements = false
Capybara.asset_host = 'http://localhost:3000'
