require 'spec_helper'

module Sipity
  module Services
    RSpec.describe AuthenticationLayer do
      let(:controller) { double(redirect_to: true, session: session, :current_user= => true) }
      let(:session) { {} }
      let(:token) { 'A Cogitate Token' }
      let(:user) { double('Current User', signed_in?: false, agreed_to_application_terms_of_service?: false) }
      let(:current_user_extractor) { double(call: user) }

      subject { described_class.new(context: controller, current_user_extractor: current_user_extractor) }

      it 'will capture the cogitate_token in the session' do
        expect { subject.capture_cogitate_token(token: token) }.to change { session[:cogitate_data] }.from(nil).to(token)
      end

      it 'will expose .authenticate_user! as a convenience method' do
        expect_any_instance_of(described_class).to receive(:authenticate_user!)
        described_class.authenticate_user!(controller)
      end

      it 'will expose .authenticate_user_with_disregard_for_approval_of_terms_of_service! as a convenience method' do
        expect_any_instance_of(described_class).to receive(:authenticate_user_with_disregard_for_approval_of_terms_of_service!)
        described_class.authenticate_user_with_disregard_for_approval_of_terms_of_service!(controller)
      end

      it 'will expose .default! as a convenience method' do
        expect_any_instance_of(described_class).to receive(:authenticate_user!)
        described_class.default!(controller)
      end

      it 'will expose .none! as a convenience method' do
        expect(described_class.none!(controller)).to eq(true)
      end

      context 'when the user is not signed in' do
        let(:user) { double(signed_in?: false) }
        context '#authenticate_user!' do
          it 'will redirect to to the authenticate path' do
            expect(controller).to receive(:redirect_to).with('/authenticate')
            subject.authenticate_user!
          end
          it 'will return false' do
            expect(subject.authenticate_user!).to eq(false)
          end
        end
        context '#authenticate_user_with_disregard_for_approval_of_terms_of_service!' do
          it 'will redirect to to the authenticate path' do
            expect(controller).to receive(:redirect_to).with('/authenticate')
            subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!
          end
          it 'will return false' do
            expect(subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!).to eq(false)
          end
        end
      end
      context 'when the user is signed in but has NOT agreed to the application ToS' do
        let(:user) { double(signed_in?: true, agreed_to_application_terms_of_service?: false) }
        context '#authenticate_user!' do
          it 'will redirect to to the account path' do
            expect(controller).to receive(:redirect_to).with('/account')
            subject.authenticate_user!
          end
          it 'will return false' do
            expect(subject.authenticate_user!).to eq(false)
          end
        end
        context '#authenticate_user_with_disregard_for_approval_of_terms_of_service!' do
          it 'will not redirect' do
            expect(controller).to_not receive(:redirect_to)
            subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!
          end
          it 'will return the current user' do
            expect(subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!).to eq(user)
          end
        end
      end
      context 'when the user is signed in and has agreed to the application ToS' do
        let(:user) { double(signed_in?: true, agreed_to_application_terms_of_service?: true) }
        context '#authenticate_user!' do
          it 'will not redirect' do
            expect(controller).to_not receive(:redirect_to)
            subject.authenticate_user!
          end
          it 'will return the current user' do
            expect(subject.authenticate_user!).to eq(user)
          end
        end
        context '#authenticate_user_with_disregard_for_approval_of_terms_of_service!' do
          it 'will not redirect' do
            expect(controller).to_not receive(:redirect_to)
            subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!
          end
          it 'will return the current user' do
            expect(subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!).to eq(user)
          end
        end
      end
    end
  end
end
