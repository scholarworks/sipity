require "rails_helper"
require 'sipity/controllers/collaborator_presenter'

module Sipity
  module Controllers
    RSpec.describe CollaboratorPresenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user, render: true) }
      let(:current_user) { double }

      let(:collaborator) { double(name: 'The Name', role: 'The Role') }
      subject { described_class.new(context, collaborator: collaborator) }

      it { is_expected.to delegate_method(:name).to(:collaborator) }
      it { is_expected.to delegate_method(:role).to(:collaborator) }

      it 'exposes a label that takes an identifier' do
        expect(subject.label('role')).to eq('Role')
      end

      context 'for a netid-based collaborator' do
        let(:collaborator) { double(name: 'The Name', role: 'The Role', netid?: true, netid: 'hello-world') }

        it 'will label collaborator_identifier as Netid' do
          expect(subject.label(described_class::COLLABORATOR_IDENTIFIER_PREDICATE)).to eq('NetID')
        end

        it 'will have collaborator_identifier that is the Netid' do
          expect(subject.collaborator_identifier).to be_html_safe
          expect(subject.collaborator_identifier).to include(collaborator.netid)
        end
      end

      context 'for a non-netid-based collaborator' do
        let(:is_netid) { true }
        let(:collaborator) { double(name: 'The Name', role: 'The Role', netid?: false, email: 'hello-world@world.com') }

        it 'will label collaborator_identifier as Netid' do
          expect(subject.label(described_class::COLLABORATOR_IDENTIFIER_PREDICATE)).to eq('Email')
        end

        it 'will have collaborator_identifier that is the Netid' do
          expect(subject.collaborator_identifier).to be_html_safe
          expect(subject.collaborator_identifier).to include(collaborator.email)
        end
      end
    end
  end
end
