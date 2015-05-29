require 'spec_helper'

module Sipity
  module Parameters
    RSpec.describe EntityWithCommentsParameter do
      let(:comments) { double }
      let(:entity) { double }
      subject { described_class.new(comments: comments, entity: entity) }
      its(:entity) { should eq entity }
      its(:comments) { should eq comments }
    end
  end
end