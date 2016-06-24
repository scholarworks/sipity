require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe CommentPresenter do
      let(:context) { PresenterHelper::Context.new }
      let(:comment) { double(comment: 'Hello World', name_of_commentor: 'My Name') }
      subject { described_class.new(context, comment: comment) }

      its(:message) { is_expected.to eq(comment.comment) }
      its(:name_of_commentor) { is_expected.to eq(comment.name_of_commentor) }
    end
  end
end
