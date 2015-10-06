require 'spec_helper'
require 'sipity/decorators/emails/processing_comment_decorator'

module Sipity
  module Decorators
    module Emails
      RSpec.describe ProcessingCommentDecorator do
        let(:user) { User.new(name: 'Hello World', username: 'hworld') }
        let(:work) { Models::Work.new(id: 'abc', work_type: 'doctoral_dissertation', title: 'My Title') }
        let(:entity) { Models::Processing::Entity.new(proxy_for: work) }
        let(:processing_comment) do
          Models::Processing::Comment.new(comment: 'hello', identifier_id: PowerConverter.convert(user, to: :identifier_id), entity: entity)
        end
        let(:repository) { QueryRepositoryInterface.new }
        subject { described_class.new(processing_comment, repository: repository) }

        context '.decorate' do
          it 'is an alterate to .new' do
            expect(described_class.decorate(processing_comment, repository: repository)).to be_a(described_class)
          end
        end

        its(:default_repository) { should respond_to(:get_identifiable_agent_for) }
        its(:comment) { should eq processing_comment.comment }
        before { allow(repository).to receive(:get_identifiable_agent_for).and_return(user) }
        its(:name_of_commentor) { should eq(user.name) }
        its(:work_type) { should eq('Doctoral dissertation') }
        its(:title) { should eq(work.title) }
        its(:created_date) do
          expect(subject).to receive(:created_at).and_return(Time.zone.now)
          should be_a(String)
        end
        its(:email_message_action_description) { should eq("Review comments for “#{work.title}”") }
        its(:email_message_action_name) { should eq("Review comments") }
        its(:email_message_action_name) { should eq("Review comments") }
        its(:email_message_action_url) { should match(%r{/#{work.to_param}\Z}) }
      end
    end
  end
end
