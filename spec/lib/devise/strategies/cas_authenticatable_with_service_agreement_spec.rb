require 'spec_helper'
require 'devise/strategies/cas_authenticatable_with_service_agreement'

module Devise
  module Strategies
    RSpec.describe CasAuthenticationWithServiceAgreement do
      let(:env) { { 'rack.session' => {} } }
      subject { described_class.new(env) }
      it 'will store the validated user id in the session' do
        resource = User.new(id: 123, agreed_to_terms_of_service: true)
        expect { subject.success!(resource) }.
          to change { env['rack.session'] }.
          from({}).to(Devise::Strategies::VALIDATED_RESOURCE_ID_SESSION_KEY => resource.id)
      end

      it 'will be successful if the user has agreed_to_terms_of_service' do
        resource = User.new(id: 123, agreed_to_terms_of_service: true)
        expect { subject.success!(resource) }.
          to change { subject.instance_variable_get("@user") }.from(nil).to(resource)
      end

      it 'will not be successful if the user has not agreed_to_terms_of_service' do
        expect(subject.request).to receive(:url).and_return('http://test.com')
        expect(subject).to receive(:redirect!).
          with(File.join("http://test.com", Devise::Strategies::TERMS_OF_SERVICE_AGREEMENT_PATH))
        resource = User.new(id: 123, agreed_to_terms_of_service: false)
        expect { subject.success!(resource) }.
          to_not change { subject.instance_variable_get("@user") }
      end
    end

    RSpec.describe ValidatedButTermsOfServiceAgreementNotRequired do
      context 'with a validated session resource id' do
        let!(:resource) { User.create!(username: 'hello', agreed_to_terms_of_service: true) }
        let(:env) { { 'rack.session' => { Devise::Strategies::VALIDATED_RESOURCE_ID_SESSION_KEY => resource.id } } }
        subject { described_class.new(env) }

        before do
          allow(subject).to receive(:mapping).and_return(Devise.mappings.fetch(:user))
        end

        it 'will be valid if the session has been set' do
          expect(subject).to be_valid
        end

        it 'will be successful if the resource is found' do
          expect(subject).to receive(:success!).with(resource)
          subject.authenticate!
        end

        context 'with user id that is missing' do
          let(:env) { { 'rack.session' => { Devise::Strategies::VALIDATED_RESOURCE_ID_SESSION_KEY => '-1' } } }
          it 'will raise if the resource is not found' do
            expect(subject).to receive(:fail!).with(:invalid)
            subject.authenticate!
          end
        end
      end

      context 'without a validated session resource id' do
        let(:env) { { 'rack.session' => {} } }
        subject { described_class.new(env) }

        it 'will not be valid if the session has been set' do
          expect(subject).to_not be_valid
        end
      end
    end
  end
end
