require 'rails_helper'

RSpec.describe 'sipity/controllers/works/new.html.erb', type: :view do
  let(:model) { Sipity::Decorators::WorkDecorator.decorate(Sipity::Forms::CreateWorkForm.new) }

  it 'renders the object and fieldsets' do
    # I want to pass the model to the view; Not using an instance variable
    render template: 'sipity/controllers/works/new', locals: { model: model }
    expect(rendered).to have_tag('form.new_work[action="/works"][method="post"]') do
      with_tag('fieldset.attributes_work') do
        with_tag('textarea', with: { name: 'work[title]' })
      end
      with_tag('fieldset.work_publication_strategy_work') do
        model.work_publication_strategies_for_select.each do |name|
          with_tag('input', with: { name: 'work[work_publication_strategy]', value: name })
        end
      end
      with_tag('.action-pane') do
        with_tag('input', with: { type: 'submit' })
      end
    end
  end
end
