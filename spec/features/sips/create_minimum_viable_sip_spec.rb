require 'rails_helper'

feature 'Minimum viable SIP', :devise do
  include Warden::Test::Helpers
  before { Warden.test_mode! }
  let(:user) { FactoryGirl.create(:user) }
  scenario 'User can create a SIP' do
    login_as(user, scope: :user)
    visit '/start'
    on('new_sip_header') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:title, with: 'Hello World')
      the_page.choose(:work_publication_strategy, with: 'do_not_know')
      # Oh nested attributes. What lengths I go to!
      the_page.fill_in('collaborators_attributes][0][name', with: 'Robert the Bruce')
      the_page.select(Sip::Models::Collaborator::DEFAULT_ROLE, from: 'collaborators_attributes][0][role')
      the_page.submit_button.click
    end

    on('sip_header') do |the_page|
      expect(the_page.text_for('title')).to eq(['Hello World'])
      expect(the_page.text_for('work_publication_strategy')).to eq(['do_not_know'])
      expect(the_page.text_for('collaborators .value.name')).to eq(['Robert the Bruce'])
      the_page.click_recommendation('DOI')
    end

    on('assign_doi_page') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:identifier, with: 'abc:123')
      the_page.submit_button.click
    end

    on('sip_header') do |the_page|
      the_page.click_edit
    end

    on('edit_sip_header') do |the_page|
      the_page.fill_in(:title, with: 'New Value')
      the_page.submit_button.click
    end

    on('sip_header') do |the_page|
      expect(the_page.text_for('title')).to eq(['New Value'])
    end
  end

  # Given a user has filled out a publication date at creation
  # When they go to request a DOI
  # Then the publication_date is displayed
  # And cannot be changed

end
