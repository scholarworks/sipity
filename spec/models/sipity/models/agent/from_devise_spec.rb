require 'spec_helper'
module Sipity
  module Models
    class Agent
      RSpec.describe FromDevise do
        let(:user) { User.new(username: 'hello', id: 123) }
        let(:repository) { QueryRepositoryInterface.new }
        subject { described_class.new(user: user, repository: repository) }
        its(:default_repository) { should respond_to(:agreed_to_application_terms_of_service?) }
        its(:email) { should eq(user.email) }
        its(:name) { should eq(user.to_s) }
        its(:ids) { should eq([subject.identifier_id]) }
        its(:user_id) { should eq(user.id) }
        its(:id) { should eq(user.id) }
        its(:user_signed_in?) { should eq(true) }
        its(:to_polymorphic_type) { should eq('User') }
        context '#agreed_to_application_terms_of_service?' do
          it 'will use the given repository and identifier' do
            expect(repository).to receive(
              :agreed_to_application_terms_of_service?
            ).with(identifier_id: subject.identifier_id).and_return(true)
            expect(subject.agreed_to_application_terms_of_service?).to eq(true)
          end
        end
      end
    end
  end
end
