require 'spec_helper'
require 'sipity/runners/comment_runners'
require 'sipity/runners/comment_runners'

module Sipity
  module Runners
    module CommentRunners
      include RunnersSupport

      RSpec.describe Index do
        let(:work) { double }
        let(:user) { double('User') }
        let(:context) { TestRunnerContext.new(find_work_by: work, current_user: user) }
        let(:handler) { double(invoked: true) }
        subject do
          described_class.new(context, authentication_layer: false, authorization_layer: false) do |on|
            on.success { |a| handler.invoked("SUCCESS", a) }
          end
        end

        it 'will require authentication by default' do
          expect(described_class.authentication_layer).to eq(:default)
        end

        it 'enforces authorization' do
          expect(described_class.authorization_layer).to eq(:default)
        end

        it 'issues the :success callback' do
          response = subject.run(work_id: 1234)
          expect(handler).to have_received(:invoked).with("SUCCESS", work)
          expect(response).to eq([:success, work])
        end
      end
    end
  end
end
