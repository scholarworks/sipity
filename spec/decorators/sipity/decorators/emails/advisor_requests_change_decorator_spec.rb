require 'spec_helper'

module Sipity
  module Decorators
    module Emails
      RSpec.describe AdvisorRequestsChangeDecorator do
        let(:processing_comment) { Models::Processing::Comment.new(comment: 'hello') }
        subject { described_class.new(processing_comment) }

        its(:comment) { should eq processing_comment.comment }
        it { should respond_to :name_of_commentor }
        it { should respond_to :document_type }
      end
    end
  end
end
