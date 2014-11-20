require 'rails_helper'

RSpec.describe 'sip/headers/new.html.erb', type: :view do
  let(:model) { Sip::Header.new.decorate }

  it 'renders the object and fieldsets' do
    # I want to pass the model to the view; Not using an instance variable
    render template: 'sip/headers/new', locals: { model: model }
    expect(rendered).to have_tag('form.new_sip_header[action="/sip/headers"][method="post"]') do
      with_tag('fieldset.attributes_sip_header') do
        with_tag('input', with: { name: 'sip_header[title]' })
      end
      with_tag('fieldset.attributes_sip_header') do
        with_tag('input', with: { type: 'submit' })
      end
    end
  end
end
