require 'spec_helper'

module Sipity
  module Decorators
    module Emails
      RSpec.describe WorkEmailDecorator do
        let(:work) { Models::Work.new(id: 'abc', work_type: 'doctoral_dissertation', title: 'My Title') }
        subject { described_class.new(work) }

        its(:document_type) { should eq('Doctoral Dissertation') }
        its(:work_type) { should eq('Doctoral Dissertation') }
        its(:title) { should eq(work.title) }
        its(:email_message_action_description) { should eq("Review Doctoral Dissertation “#{work.title}”") }
        its(:email_message_action_name) { should eq("Review Doctoral Dissertation") }
        its(:email_message_action_url) { should match(/\/#{work.to_param}\Z/) }
        its(:email_subject) { should be_a(String) }
      end
    end
  end
end
