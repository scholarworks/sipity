require 'rails_helper'

RSpec.describe 'sipity/controllers/sips/new.html.erb', type: :view do
  let(:model) { Sipity::Decorators::SipDecorator.decorate(Sipity::Forms::CreateSipForm.new) }

  it 'renders the object and fieldsets' do
    # I want to pass the model to the view; Not using an instance variable
    render template: 'sipity/controllers/sips/new', locals: { model: model }
    expect(rendered).to have_tag('form.new_sip[action="/sips"][method="post"]') do
      with_tag('fieldset.attributes_sip') do
        with_tag('input', with: { name: 'sip[title]' })
        model.possible_work_publication_strategies.each do |name, _index|
          with_tag('input', with: { name: 'sip[work_publication_strategy]', value: name })
        end
      end
      with_tag('fieldset.collaborators_sip') do
        with_tag('input', with: { name: 'sip[collaborators_attributes][0][name]' })
        with_tag('select', with: { name: 'sip[collaborators_attributes][0][role]' })
      end
      with_tag('fieldset.attributes_sip') do
        with_tag('input', with: { type: 'submit' })
      end
    end
  end
end
