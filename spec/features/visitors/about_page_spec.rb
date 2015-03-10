# Feature: 'About' page
#   As a visitor
#   I want to visit an 'about' page
#   So I can learn more about the website
feature 'About page', :feature do

  # Scenario: Visit the 'about' page
  #   Given I am a visitor
  #   When I visit the 'about' page
  #   Then I see "About the Website"
  scenario 'Visit the about page' do
    visit 'about'

    # NOTE: Defaulting to I18n keys; it is a weak match
    expect(page).to have_content 'Title Html'
    expect(page).to have_content 'Body Html'
  end

end
