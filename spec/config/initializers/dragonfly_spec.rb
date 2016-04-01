require 'rails_helper'

RSpec.describe 'config/initializers/dragonfly.rb' do
  context 'configuration' do
    context 'for Dragonfly.app.server' do
      subject { Dragonfly.app.server }
      its(:url_host) { is_expected.to be_present }
      its(:url_format) { is_expected.to eq "/attachments/:job/:name" }
    end
    context 'for Dragonfly.app' do
      subject { Dragonfly.app }
      its(:secret) { is_expected.to be_present }
      its(:response_headers) { is_expected.to eq("Cache-Control" => "private, max-age=10800") }
    end
  end
end
