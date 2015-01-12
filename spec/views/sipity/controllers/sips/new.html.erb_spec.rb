require 'rails_helper'

RSpec.describe 'sipity/controllers/sips/new.html.erb', type: :view do
  let(:model) { Sipity::Decorators::SipDecorator.decorate(Sipity::Forms::CreateSipForm.new) }

  it 'renders the object and fieldsets' do
    # I want to pass the model to the view; Not using an instance variable
    render template: 'sipity/controllers/sips/new', locals: { model: model }
    expect(rendered).to have_tag('form.new_sip[action="/sips"][method="post"]') do
      with_tag('fieldset.attributes_sip') do
        with_tag('input', with: { name: 'sip[title]' })
      end
      with_tag('fieldset.work_publication_strategy_sip') do
        model.work_publication_strategies_for_select.each do |name|
          with_tag('input', with: { name: 'sip[work_publication_strategy]', value: name })
        end
      end
      with_tag('fieldset.actions_sip') do
        with_tag('input', with: { type: 'submit' })
      end
    end
  end
end
