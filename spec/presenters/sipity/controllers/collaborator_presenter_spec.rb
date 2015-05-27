require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe CollaboratorPresenter do
      let(:context) { PresenterHelper::Context.new(current_user: current_user, render: true) }
      let(:current_user) { double }

      let(:collaborator) { double(name: 'The Name', role: 'The Role') }
      subject { described_class.new(context, collaborator: collaborator) }

      it { should delegate_method(:name).to(:collaborator) }
      it { should delegate_method(:role).to(:collaborator) }

      it 'exposes a label that takes an identifier' do
        expect(subject.label('role')).to eq('Role')
      end
    end
  end
end
