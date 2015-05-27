require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe AdditionalAttributePresenter do
      let(:additional_attribute) { double(key: 'the_key', values: ['a', 'b']) }
      let(:context) { PresenterHelper::Context.new }
      subject { described_class.new(context, additional_attribute: additional_attribute) }

      it { should delegate_method(:key).to(:additional_attribute) }
      it { should delegate_method(:values).to(:additional_attribute) }
      its(:label) { should be_a(String) }
      its(:render_list_of_values) { should be_html_safe }
    end
  end
end
