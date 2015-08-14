require 'spec_helper'

describe 'cogitate integration routing spec', type: :routing do
  it 'will route the Cogitate.configuration.after_authentication_callback_url' do
    expect(get: Cogitate.configuration.after_authentication_callback_url).to(
      route_to(controller: 'sipity/controllers/sessions', action: 'create')
    )
  end

  it 'will route /authenticate' do
    expect(get: 'authenticate').to(
      route_to(controller: 'sipity/controllers/sessions', action: 'new')
    )
  end
end
