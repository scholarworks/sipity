require 'spec_helper'
require 'sipity/decorators'

module Sipity
  RSpec.describe Decorators do
    context '.ComparableDelegateClass' do
      let(:underlying_object) { double }
      subject { described_class.ComparableDelegateClass(underlying_object.class) }
      its(:base_class) { should eq(double.class) }
      it { should be_a Class }
      it { should respond_to :new }
    end
  end
end
