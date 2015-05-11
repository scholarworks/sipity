require 'spec_helper'

module Sipity
  module Parameters
    RSpec.describe ActionSet do
      let(:identifier) { double }
      let(:collection) { double }
      subject { described_class.new(identifier: identifier, collection: collection) }
      its(:identifier) { should eq identifier }
      its(:collection) { should eq collection }
    end
  end
end
