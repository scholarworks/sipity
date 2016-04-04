require 'spec_helper'
require 'sipity/parameters/entity_with_comments_parameter'

module Sipity
  module Parameters
    RSpec.describe EntityWithCommentsParameter do
      let(:comments) { double }
      let(:entity) { double }
      subject { described_class.new(comments: comments, entity: entity) }
      its(:entity) { is_expected.to eq entity }
      its(:comments) { is_expected.to eq comments }
    end
  end
end
