require 'spec_helper'
require 'sipity/controllers'

module Sipity
  RSpec.describe Controllers do
    subject { described_class }
    it 'will allow you to #build_processing_action_view_path_for' do
      expect(subject.build_processing_action_view_path_for(slug: 'hello')).to match(%r{/hello\Z})
    end
  end
end
