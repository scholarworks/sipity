require 'rails_helper'

feature "Trigger Work State Change", :devise do
  include Warden::Test::Helpers
  let(:user) { Sipity::Factories.create_user }

  context 'with no required todo items' do
    before do
      # Because Email may not be configured, I'm jumping in and saying "Don't
      # worry about any deliveries."
      expect(Sipity::Services::Notifier).to receive(:deliver).at_least(:once)
    end

    scenario 'User can advance an object through state' do
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
        expect { the_page.find_named_object('event_trigger>submit_for_review') }.
          to raise_error(Capybara::ElementNotFound)
      end
    end
  end

  context 'with required TODO Items' do
    before do
      Sipity::Models::WorkTypeTodoListConfig.create!(
        work_type: 'etd',
        work_processing_state: 'new',
        enrichment_type: 'describe',
        enrichment_group: 'required'
      )
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
        # Because there are no required steps; I can continue
        expect { the_page.find_named_object('event_trigger>submit_for_review').find('[itemprop="url"]') }.
          to raise_error(Capybara::ElementNotFound)
      end
    end
  end
end
