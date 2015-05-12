require 'spec_helper'
require 'sipity/parameters/entity_with_comments_parameter'

module Sipity
  module Controllers
    RSpec.describe CurrentCommentsPresenter do
      let(:context) { PresenterHelper::Context.new(work_comments_path: 'work_comments_path') }
      let(:current_comments) { Parameters::EntityWithCommentsParameter.new(entity: double, comments: [double, double]) }
      subject { CurrentCommentsPresenter.new(context, current_comments: current_comments) }

      its(:comments) { should eq(current_comments.comments) }
      its(:path_to_all_comments) { should be_a(String) }
    end
  end
end
