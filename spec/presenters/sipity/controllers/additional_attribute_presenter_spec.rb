require "rails_helper"
require 'sipity/controllers/additional_attribute_presenter'

module Sipity
  module Controllers
    RSpec.describe AdditionalAttributePresenter do
      let(:additional_attribute) { double(key: 'the_key', values: ['a', 'b'], entity: double) }
      let(:context) { PresenterHelper::Context.new }
      subject { described_class.new(context, additional_attribute: additional_attribute) }

      it { is_expected.to delegate_method(:key).to(:additional_attribute) }
      it { is_expected.to delegate_method(:values).to(:additional_attribute) }
      its(:label) { is_expected.to be_a(String) }
      its(:render_list_of_values) { is_expected.to be_html_safe }

      it 'will translate the key into a label' do
        expect(TranslationAssistant).to receive(:call)
        subject.label
      end

      [
        { key: 'work_patent_strategy', value: 'hello_world', expected: 'Hello World' },
        { key: 'work_publication_strategy', value: 'hello_world', expected: 'Hello World' },
        { key: 'chicken_nugget', value: 'hello_world', expected: 'hello_world' }
      ].each do |the_test|
        it "will render '#{the_test[:key]}' with value: #{the_test.fetch(:value)}" do
          additional_attribute = double(key: the_test[:key], values: the_test.fetch(:value), entity: double)
          subject = described_class.new(context, additional_attribute: additional_attribute)
          expect(subject.render_list_of_values).to include(the_test[:expected])
        end
      end
    end
  end
end
