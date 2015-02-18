require 'rails_helper'

feature 'Enriching a Work', :devise, :feature do
  include Warden::Test::Helpers
  before do
    Sipity::SpecSupport.load_database_seeds!
    Warden.test_mode!
  end
  let(:user) { Sipity::Factories.create_user }

  def create_a_work(options = {})
    visit '/start'
    on('new_work_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:title, with: options.fetch(:title, 'Hello World'))
      the_page.select(options.fetch(:work_type, 'etd'), from: :work_type)
      the_page.choose(:work_publication_strategy, with: options.fetch(:work_publication_strategy, 'do_not_know'))
      the_page.submit_button.click
    end
  end

  def attach_file_work
    login_as(user, scope: :user)
    create_a_work(work_type: 'etd')

    on('work_page') do |the_page|
      the_page.click_todo_item('enrichment/required/attach')
    end

    on('attach_page') do |the_page|
      the_page.attach_file(__FILE__)
      the_page.submit_button.click
    end
  end

  scenario 'User creates a work then sees it on their dashboard' do
    login_as(user, scope: :user)
    create_a_work(work_type: 'etd', title: 'Hello World', work_publication_strategy: 'do_not_know')
    visit '/dashboard'
  end

  scenario 'User can create a Work' do
    login_as(user, scope: :user)
    create_a_work(work_type: 'etd', title: 'Hello World', work_publication_strategy: 'do_not_know')

    on('work_page') do |the_page|
      expect(the_page.text_for('title')).to eq(['Hello World'])
      expect(the_page.text_for('work_publication_strategy')).to eq(['do_not_know'])
      the_page.click_recommendation('DOI')
    end

    on('assign_doi_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:identifier, with: 'abc:123')
      the_page.submit_button.click
    end

    on('work_page') do |the_page|
      the_page.click_edit
    end

    on('edit_work_page') do |the_page|
      the_page.fill_in(:title, with: 'New Value')
      the_page.submit_button.click
    end

    on('work_page') do |the_page|
      expect(the_page.text_for('title')).to eq(['New Value'])
      the_page.click_recommendation('Citation')
    end

    on('new_citation_page') do |the_page|
      the_page.fill_in(:citation, with: 'This is My Citation')
      the_page.fill_in(:type, with: 'ALA')
      the_page.submit_button.click
    end
  end

  scenario 'User can describe additional data' do
    login_as(user, scope: :user)
    create_a_work(work_type: 'etd')

    on('work_page') do |the_page|
      the_page.click_todo_item('enrichment/required/describe')
    end

    on('describe_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:abstract, with: 'Lorem ipsum')
      the_page.submit_button.click
    end

    on('work_page') do |the_page|
      expect(the_page.todo_item_named_status_for('enrichment/required/describe')).to eq('done')
    end
  end

  scenario 'User can attach files' do
    login_as(user, scope: :user)
    create_a_work(work_type: 'etd')

    on('work_page') do |the_page|
      the_page.click_todo_item('enrichment/required/attach')
    end

    on('attach_page') do |the_page|
      expect(the_page).to have_input_file
      the_page.attach_file(__FILE__)
    end
  end

  scenario 'User can remove files' do
    attach_file_work
  end

  scenario 'User can add collaborators' do
    login_as(user, scope: :user)
    create_a_work(work_type: 'etd')

    on('work_page') do |the_page|
      the_page.click_todo_item('enrichment/required/collaborators')
    end

    on('collaborators_page') do |the_page|
      expect(the_page).to be_all_there
    end
  end
end
