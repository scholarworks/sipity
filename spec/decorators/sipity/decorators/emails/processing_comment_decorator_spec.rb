require 'spec_helper'

module Sipity
  module Decorators
    module Emails
      RSpec.describe ProcessingCommentDecorator do
        let(:user) { User.new(name: 'Hello World') }
        let(:work) { Models::Work.new(id: 'abc', work_type: 'doctoral_dissertation', title: 'My Title') }
        let(:actor) { Models::Processing::Actor.new(proxy_for: user) }
        let(:entity) { Models::Processing::Entity.new(proxy_for: work) }
        let(:processing_comment) { Models::Processing::Comment.new(comment: 'hello', actor: actor, entity: entity) }
        subject { described_class.new(processing_comment) }

        its(:comment) { should eq processing_comment.comment }
        its(:name_of_commentor) { should eq(user.name) }
        its(:work_type) { should eq('Doctoral dissertation') }
        its(:title) { should eq(work.title) }
        its(:email_message_action_description) { should eq("Review comments for “#{work.title}”") }
        its(:email_message_action_name) { should eq("Review comments") }
        its(:email_message_action_name) { should eq("Review comments") }
        its(:email_message_action_url) { should match(%r{/#{work.to_param}\Z}) }
      end
    end
  end
end
