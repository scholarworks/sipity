require 'spec_helper'
require 'sipity'
require 'sipity'

RSpec.describe Sipity do
  subject { described_class }
  its(:table_name_prefix) { is_expected.to eq('sipity_') }

  it 'exposes #t as a helper method for translations' do
    keywords = { scope: 'hello', subject: 'world' }
    expect(Sipity::Controllers::TranslationAssistant).to receive(:call).with(keywords)
    Sipity.t(keywords)
  end

  context '.support_statement_container_html' do
    context 'with a view_object' do
      let(:view_object) { double(to_work_area: Sipity::Models::WorkArea.new(slug: 'etd')) }
      let(:template) { double(view_object: view_object) }
      it "leverages the view object's work area to build a translation key" do
        expect(I18n).to receive(:t).with(
          :"application.work_areas.etd.support_statement_container_html",
          default: [:'application.support_statement_container_html'],
          fallback: ''
        ).and_call_original
        Sipity.support_statement_container_html(template: template)
      end

      it "gracefully degrades if no view object is present" do
        expect(I18n).to receive(:t).with(:'application.support_statement_container_html', default: [], fallback: '').and_call_original
        Sipity.support_statement_container_html(template: double(view_object: double))
      end
    end

    context 'without a view_object' do
      let(:template) { double }
      it 'exposes .render_application_footer for translating footer methods' do
        expect(I18n).to receive(:t).with(:'application.support_statement_container_html', default: [], fallback: '').and_call_original
        Sipity.support_statement_container_html(template: template)
      end
    end
  end
end
