require 'spec_helper'
require 'sipity/controllers/additional_attribute_set_presenter'

module Sipity
  module Controllers
    RSpec.describe AdditionalAttributeSetPresenter, type: :presenter do
      let(:additional_attribute_set) { double(additional_attributes: double) }
      let(:context) { PresenterHelper::Context.new }
      subject { described_class.new(context, additional_attribute_set: additional_attribute_set) }
      it { is_expected.to delegate_method(:additional_attributes).to(:additional_attribute_set) }
    end
  end
end
