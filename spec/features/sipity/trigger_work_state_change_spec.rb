require 'rails_helper'

feature "Trigger Work State Change", :devise, :feature do
  include Warden::Test::Helpers
  before do
    Sipity::SpecSupport.load_database_seeds!(seeds_path: 'spec/fixtures/seeds/trigger_work_state_change.rb')
    Warden.test_mode!
  end

  let(:user) { Sipity::Factories.create_user }

  context 'with required TODO Items' do
    before do
      allow(Sipity::Services::Notifier).to receive(:deliver)
    end
    scenario 'User will not see option to advance state if todo items are not done' do
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
        # Because there are required steps; I cannot continue
        expect { the_page.find_named_object('event_trigger/submit_for_review').find('[itemprop="url"]') }.
          to raise_error(Capybara::ElementNotFound)
      end

      on('work_page') do |the_page|
        the_page.click_todo_item('todo/required/describe')
      end

      on('describe_page') do |the_page|
        expect(the_page).to be_all_there
        the_page.fill_in(:abstract, with: 'Lorem ipsum')
        the_page.submit_button.click
      end

      on('work_page') do |the_page|
        expect(the_page.processing_state).to eq('new')
        # Because there are no required steps; I can continue
        the_page.take_named_action('event_trigger/submit_for_review')
      end

      on('event_trigger_page') do |the_page|
        the_page.take_named_action('confirm/event_trigger/submit_for_review')
      end

      on('work_page') do |the_page|
        # The state was advanced
        expect(the_page.processing_state).to eq('under_review')
        expect { the_page.find_named_object('event_trigger/submit_for_review') }.
          to raise_error(Capybara::ElementNotFound)
      end
    end
  end
end
