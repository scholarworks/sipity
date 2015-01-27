require 'rails_helper'

feature "Trigger Work State Change", :devise do
  include Warden::Test::Helpers
  let(:user) { Sipity::Factories.create_user }
  before do
    # Because Email may not be configured, I'm jumping in and saying "Don't
    # worry about any deliveries."
    expect(Sipity::Services::Notifier).to receive(:deliver).at_least(:once)
  end

  scenario 'User can create a SIP' do
    login_as(user, scope: :user)
    visit '/start'
    login_as(user, scope: :user)
    visit '/start'
    on('new_work_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:title, with: 'Hello World')
      the_page.select('etd', from: :work_type)
      the_page.choose(:work_publication_strategy, with: 'do_not_know')
      the_page.submit_button.click
    end

    on('work_page') do |the_page|
      expect(the_page.processing_state).to eq('new')
      # Because there are no required steps; I can continue
      the_page.take_named_action('event_trigger>submit_for_review')
    end

    on('event_trigger_page') do |the_page|
      the_page.take_named_action('confirm>event_trigger>submit_for_review')
    end

    on('work_page') do |the_page|
      # The state was advanced
      expect(the_page.processing_state).to eq('under_review')
    end
  end
end
