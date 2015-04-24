require 'rails_helper'

feature 'Interacting with a Work Area', :devise, :feature do
  include Warden::Test::Helpers
  before do
    Warden.test_mode!
  end
  let(:user) { Sipity::Factories.create_user }
  let(:slug) { 'worm' }

  scenario 'User will not see the work area if they do not have authorization' do
    Sipity::Services::CreateWorkAreaService.call(name: slug)

    login_as(user, scope: :user)
    expect { visit("/areas/#{slug}") }.to raise_error(Sipity::Exceptions::AuthorizationFailureError)
  end
end
