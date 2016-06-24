require 'rails_helper'
require 'sipity/services/authorization_layer'

module Sipity
  module Services
    RSpec.describe AuthorizationLayer do
      subject { described_class.new(context, policy_authorizer: policy_authorizer) }
      let(:entity) { Models::Work.new(id: '2', title: 'dummy') }
      let(:context) { double(current_user: User.new(id: '1')) }
      let(:action_to_authorize) { :create? }
      let(:policy_authorizer) { double('PolicyAuthorizer', call: :called) }

      it 'will have a default policy_authorizer' do
        authorization_layer = described_class.new(context)
        expect(authorization_layer.send(:policy_authorizer)).to respond_to(:call)
      end

      context '.without_authorization_to_attachment' do
        let(:file_uid) { 'abc' }
        it 'will yield if no user is given' do
          expect { |b| described_class.without_authorization_to_attachment(file_uid: file_uid, user: nil, &b) }.to yield_control
        end
        it 'will yield if the user does not have access to the given file_uid' do
          user = User.new(id: 1)
          work = Models::Work.new(id: 2)
          file = Models::Attachment.new(work: work)
          allow_any_instance_of(ActiveRecord::Relation).to receive(:find_by!).and_return(file)
          expect(Policies).to receive(:authorized_for?).with(user: user, entity: entity, action_to_authorize: :show?).
            and_return(false)
          expect { |b| described_class.without_authorization_to_attachment(file_uid: file_uid, user: user, &b) }.to yield_control
        end
        it 'will not yield control if the user is authorized to the given file' do
          user = User.new(id: 1)
          work = Models::Work.new(id: 2)
          file = Models::Attachment.new(work: work)
          allow_any_instance_of(ActiveRecord::Relation).to receive(:find_by!).and_return(file)
          expect(Policies).to receive(:authorized_for?).with(user: user, entity: entity, action_to_authorize: :show?).
            and_return(true)
          expect { |b| described_class.without_authorization_to_attachment(file_uid: file_uid, user: user, &b) }.to_not yield_control
        end
      end

      context '#enforce!' do
        let(:user) { User.new }

        context 'when each policy is authorized' do
          it 'will yield to the caller' do
            allow(policy_authorizer).to receive(:call).and_return(true)
            expect { |b| subject.enforce!(show?: entity, edit?: entity, &b) }.
              to yield_control
          end
        end

        context 'when one of the policies is unauthorized' do
          before { allow(policy_authorizer).to receive(:call).and_return(false) }
          it 'will raise an exception and not yield to the caller' do
            allow(policy_authorizer).to receive(:call).
              with(user: context.current_user, action_to_authorize: :create?, entity: entity).and_return(true)
            allow(policy_authorizer).to receive(:call).
              with(user: context.current_user, action_to_authorize: :show?, entity: entity).and_return(false)
            expect do |b|
              expect do
                subject.enforce!(create?: entity, show?: entity, &b)
              end.to raise_exception(Exceptions::AuthorizationFailureError)
            end.to_not yield_control
          end

          it 'will issue an :unauthorized callback if the context responds to #callback' do
            expect(context).to receive(:callback).with(:unauthorized)
            expect do
              subject.enforce!(show?: entity)
            end.to raise_exception(Exceptions::AuthorizationFailureError)
          end
        end
      end
    end

    RSpec.describe AuthorizationLayer::AuthorizeEverything do
      let(:context) { double }
      subject { described_class.new(context) }
      context '#enforce!' do
        it 'will be very permissive and always yield to the caller' do
          expect { |b| subject.enforce!(&b) }.to yield_control
        end
      end
    end
  end
end
