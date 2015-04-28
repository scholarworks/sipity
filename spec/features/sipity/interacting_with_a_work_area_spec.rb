require 'rails_helper'

feature 'Interacting with a Work Area', :devise, :feature do
  include Warden::Test::Helpers
  before do
    Warden.test_mode!
  end
  let(:user) { Sipity::Factories.create_user }
  let(:slug) { 'worm' }

  # Removed because the behavior is verified in the service object
  xscenario 'User will not see the work area if they do not have authorization' do
    Sipity::DataGenerators::FindOrCreateWorkArea.call(name: slug, slug: slug)

    login_as(user, scope: :user)
    expect { visit("/areas/#{slug}") }.to raise_error(Sipity::Exceptions::AuthorizationFailureError)
  end
end
