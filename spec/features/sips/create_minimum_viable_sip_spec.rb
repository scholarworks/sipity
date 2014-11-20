require 'rails_helper'

feature 'Minimum viable SIP', :devise do
  scenario 'User can create a SIP' do
    visit '/start'
    # on('new_sip_header') do |the_page|
    #   expect(the_page).to be_all_there
    # end

    # on('new_deposit_header') do |the_page|
    #   expect(the_page).to be_all_there
    # end
  end
end
