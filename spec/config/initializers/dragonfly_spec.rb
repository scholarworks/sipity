require 'rails_helper'

RSpec.describe 'config/initializers/dragonfly.rb' do
  context 'configuration' do
    context 'for Dragonfly.app.server' do
      subject { Dragonfly.app.server }
      its(:url_host) { should be_present }
      its(:url_format) { should eq "/attachments/:job/:name" }
    end
    context 'for Dragonfly.app' do
      subject { Dragonfly.app }
      its(:secret) { should be_present }
      its(:response_headers) { should eq("Cache-Control" => "private, max-age=10800") }
    end
  end
end
