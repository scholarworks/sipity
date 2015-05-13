require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe ProcessingActionComposer do
      let(:controller) { double(params: { processing_action_name: 'hello_world' }) }

      subject { described_class.new(controller: controller) }

      its(:processing_action_name) { should eq('hello_world') }

      it 'will prepend_processing_action_view_path_with' do
        expect(controller).to receive(:prepend_view_path).with(%r{/work_submissions/bug\Z})
        subject.prepend_processing_action_view_path_with(slug: 'bug')
      end
    end
  end
end
