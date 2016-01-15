require 'rails_helper'

feature 'Enriching a Work', :devise, :feature do
  include Warden::Test::Helpers
  before do
    Sipity::DataGenerators::FindOrCreateWorkArea.call(name: 'Electronic Thesis and Dissertation', slug: 'etd') do |work_area|
      path = Rails.root.join('app/data_generators/sipity/data_generators/submission_windows/etd_submission_windows.config.json')
      Sipity::DataGenerators::SubmissionWindowGenerator.call(work_area: work_area, path: path)
    end
    Warden.test_mode!
  end
  let(:user) { Sipity::Factories.create_user }

  def create_a_work(options = {})
    visit '/start'
    on('new_work_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:title, with: options.fetch(:title, 'Hello World'))
      the_page.select(options.fetch(:work_type, 'doctoral_dissertation'), from: :work_type)
      the_page.choose(:work_publication_strategy, with: options.fetch(:work_publication_strategy, 'do_not_know'))
      the_page.choose(:work_patent_strategy, with: options.fetch(:work_patent_strategy, 'do_not_know'))
      the_page.submit_button.click
    end
  end

  around do |example|
    Cogitate::Client.with_custom_configuration(
      client_request_handler: ->(*) { Rails.root.join('spec/fixtures/cogitate/group_with_agents.response.json').read }
    ) { example.run }
  end
  scenario 'User can enrich their submission' do
    login_as(user, scope: :user)
    create_a_work(work_type: 'doctoral_dissertation', title: 'Hello World', work_publication_strategy: 'do_not_know')

    on('work_page') do |the_page|
      # There are two because it is listed as a top-level attribute and as part
      # of the access rights.
      expect(the_page.text_for('title')).to eq(['Hello World', 'Hello World'])
      the_page.click_todo_item('enrichment/required/describe')
    end

    on('describe_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:abstract, with: 'Lorem ipsum')
      the_page.submit_button.click
    end

    on('work_page') do |the_page|
      expect(the_page.todo_item_named_status_for('enrichment/required/describe')).to eq('done')
      the_page.click_todo_item('enrichment/required/attach')
    end

    # User will see their attachments
    on('attach_page') do |the_page|
      expect(the_page).to have_input_file
      the_page.attach_file(__FILE__)
      the_page.submit_button.click
    end

    # And it shows up on the dashboard
    visit '/dashboard'
    expect(page.all(".work-listing a").map(&:text)).to eq(['Hello World'])
  end
end
