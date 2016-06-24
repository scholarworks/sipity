require "rails_helper"
require 'sipity/controllers/work_areas/filter_form_presenter'

RSpec.describe Sipity::Controllers::WorkAreas::FilterFormPresenter do
  let(:context) { PresenterHelper::ContextWithForm.new }
  let(:work_area) do
    double(
      input_name_for_select_processing_state: 'hello[world]',
      processing_state: 'new',
      processing_states_for_select: ['new', 'say'],
      input_name_for_select_sort_order: 'name[sort_order]',
      order_options_for_select: ['title', 'created_at'],
      order: 'title'
    )
  end

  subject { described_class.new(context, work_area: work_area) }

  its(:submit_button) { is_expected.to be_html_safe }
  its(:select_tag_for_processing_state) { is_expected.to be_html_safe }

  it 'will expose select_tag_for_processing_state' do
    expect(subject.select_tag_for_processing_state).to have_tag('select[name="hello[world]"]') do
      with_tag("option[value='']", text: '')
      with_tag("option[value='new'][selected='selected']", text: 'New')
      with_tag("option[value='say']", text: 'Say')
    end
  end

  it 'will expose select_tag_for_sort_order' do
    expect(subject.select_tag_for_sort_order).to have_tag('select[name="name[sort_order]"]') do
      with_tag("option[value='']", text: '')
      with_tag("option[value='title'][selected='selected']", text: 'Title')
      with_tag("option[value='created_at']", text: 'Created at')
    end
  end

  it 'will have a submit button' do
    expect(subject.submit_button).to have_tag('input.btn.btn-default[type="submit"]')
  end
end
