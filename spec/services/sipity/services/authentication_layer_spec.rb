require 'spec_helper'

module Sipity
  module Services
    RSpec.describe AuthenticationLayer do
      let(:controller) { double(redirect_to: true, session: session, :current_user= => true) }
      let(:session) { {} }
      let(:token) { 'A Cogitate Token' }
      let(:user) { double('Current User', user_signed_in?: false, agreed_to_application_terms_of_service?: false) }

      subject { described_class.new(context: controller) }

      it 'will capture the cogitate_token in the session' do
        expect { subject.capture_cogitate_token(token: token) }.to change { session[:cogitate_token] }.from(nil).to(token)
      end

      it 'will expose .authenticate_user! as a convenience method' do
        expect_any_instance_of(described_class).to receive(:authenticate_user!)
        described_class.authenticate_user!(context: controller)
      end

      it 'will expose .default! as a convenience method' do
        expect_any_instance_of(described_class).to receive(:authenticate_user!)
        described_class.default!(context: controller)
      end

      it 'will expose .none! as a convenience method' do
        expect(described_class.none!(context: controller)).to eq(true)
      end

      context '#authenticate_user!' do
        context 'when the session has no user related information' do
          it 'will redirect to the /authenticate path' do
            subject.authenticate_user!
            expect(controller).to have_received(:redirect_to).with('/authenticate')
          end

          it 'will return false' do
            expect(subject.authenticate_user!).to eq(false)
          end
        end

        context 'when the session has a cogitate_token' do
          before do
            allow(user).to receive(:user_signed_in?).and_return(true)
            allow(Sipity::Models::Agent).to receive(:new_from_cogitate_token).with(token: token).and_return(user)
          end

          it "will reify the token and set the controller's current_user" do
            subject.capture_cogitate_token(token: token)
            subject.authenticate_user!
            expect(controller).to have_received(:current_user=).with(user)
          end

          it 'will not redirect' do
            expect(controller).to_not have_received(:redirect_to)
          end
        end

        context 'when a validated_resource_id from devise is set' do
          let(:user_id) { 123 }
          before do
            session[:validated_resource_id] = user_id
            allow(user).to receive(:user_signed_in?).and_return(true)
            allow(Sipity::Models::Agent).to receive(:new_from_user_id).with(user_id: user_id).and_return(user)
          end

          it "will reify the token and set the controller's current_user" do
            subject.authenticate_user!
            expect(controller).to have_received(:current_user=).with(user)
          end

          it 'will not redirect' do
            expect(controller).to_not have_received(:redirect_to)
          end
        end

        context 'when a warden.user.user.key from devise is set' do
          let(:user_id) { 123 }
          before do
            session['warden.user.user.key'] = [[user_id], nil]
            allow(user).to receive(:user_signed_in?).and_return(true)
            allow(Sipity::Models::Agent).to receive(:new_from_user_id).with(user_id: user_id).and_return(user)
          end

          it "will reify the token and set the controller's current_user" do
            subject.authenticate_user!
            expect(controller).to have_received(:current_user=).with(user)
          end

          it 'will not redirect' do
            expect(controller).to_not have_received(:redirect_to)
          end
        end
      end
      context '#authenticate_user_with_disregard_for_approval_of_terms_of_service!' do
        context 'when the session has no user related information' do
          it 'will redirect to the /authenticate path' do
            subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!
            expect(controller).to have_received(:redirect_to).with('/authenticate')
          end

          it 'will return false' do
            expect(subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!).to eq(false)
          end
        end

        context 'when the session has a cogitate_token' do
          before do
            allow(user).to receive(:user_signed_in?).and_return(true)
            allow(Sipity::Models::Agent).to receive(:new_from_cogitate_token).with(token: token).and_return(user)
          end

          it "will reify the token and set the controller's current_user" do
            subject.capture_cogitate_token(token: token)
            subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!
            expect(controller).to have_received(:current_user=).with(user)
          end

          it 'will not redirect' do
            expect(controller).to_not have_received(:redirect_to)
          end
        end

        context 'when a validated_resource_id from devise is set' do
          let(:user_id) { 123 }
          before do
            session[:validated_resource_id] = user_id
            allow(user).to receive(:user_signed_in?).and_return(true)
            allow(Sipity::Models::Agent).to receive(:new_from_user_id).with(user_id: user_id).and_return(user)
          end

          it "will reify the token and set the controller's current_user" do
            subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!
            expect(controller).to have_received(:current_user=).with(user)
          end

          it 'will not redirect' do
            expect(controller).to_not have_received(:redirect_to)
          end
        end

        context 'when a warden.user.user.key from devise is set' do
          let(:user_id) { 123 }
          before do
            session['warden.user.user.key'] = [[user_id], nil]
            allow(user).to receive(:user_signed_in?).and_return(true)
            allow(Sipity::Models::Agent).to receive(:new_from_user_id).with(user_id: user_id).and_return(user)
          end

          it "will reify the token and set the controller's current_user" do
            subject.authenticate_user_with_disregard_for_approval_of_terms_of_service!
            expect(controller).to have_received(:current_user=).with(user)
          end

          it 'will not redirect' do
            expect(controller).to_not have_received(:redirect_to)
          end
        end
      end
    end
  end
end
