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
        the_page.select('doctoral_dissertation', from: :work_type)
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
        the_page.click_todo_item('enrichment/required/describe')
      end

      on('describe_page') do |the_page|
        expect(the_page).to be_all_there
        the_page.fill_in(:abstract, with: 'Lorem ipsum')
        the_page.submit_button.click
      end

      on('work_page') do |the_page|
        expect(the_page.processing_state).to eq('new')
        # I expect this named object to be there
        expect { the_page.find_named_object('enrichment/optional/assign_a_doi') }.to_not raise_error
        # Because there are no required steps; I can continue
        the_page.take_named_action('event_trigger/submit_for_review')
      end

      on('event_trigger_page') do |the_page|
        the_page.check('work[agree_to_terms_of_deposit]')
        the_page.take_named_action('confirm/event_trigger/submit_for_review')
      end

      on('work_page') do |the_page|
        # An action once available is no longer available
        expect { the_page.find_named_object('enrichment/optional/assign_a_doi') }.to raise_error(Capybara::ElementNotFound)
        # The state was advanced
        expect(the_page.processing_state).to eq('under_advisor_review')
        expect { the_page.find_named_object('event_trigger/submit_for_review') }.
          to raise_error(Capybara::ElementNotFound)
      end
    end
  end
end
