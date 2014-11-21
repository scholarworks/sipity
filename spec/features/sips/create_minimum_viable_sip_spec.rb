require 'rails_helper'

feature 'Minimum viable SIP', :devise do
  scenario 'User can create a SIP' do
    visit '/start'
    on('new_sip_header') do |the_page|
      expect(the_page).to be_all_there
      the_page.fill_in(:title, with: 'Hello World')
      the_page.choose(:work_publication_strategy, with: 'do_not_know')
      the_page.submit_button.click
    end

    on('sip_header') do |the_page|
      expect(the_page).to be_all_there
    end
  end
end
