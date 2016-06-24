require "rails_helper"
require 'sipity/decorators/processing/processing_comment_decorator'

module Sipity
  module Decorators
    module Processing
      RSpec.describe ProcessingCommentDecorator do
        let(:user) { User.new(name: 'Hello World') }
        let(:work) { Models::Work.new(id: 'abc', work_type: 'doctoral_dissertation', title: 'My Title') }
        let(:actor) { Models::Processing::Actor.new(proxy_for: user) }
        let(:entity) { Models::Processing::Entity.new(proxy_for: work) }
        let(:processing_comment) do
          Models::Processing::Comment.new(
            actor: actor,
            comment: 'hello',
            created_at: Time.zone.local('2015'),
            entity: entity
          )
        end
        subject { described_class.new(processing_comment) }

        its(:comment) { is_expected.to eq processing_comment.comment }
        its(:created_date) { is_expected.to match(/2015/) }
        its(:name_of_commentor) { is_expected.to eq(user.name) }
        its(:work_type) { is_expected.to eq('Doctoral Dissertation') }
      end
    end
  end
end
