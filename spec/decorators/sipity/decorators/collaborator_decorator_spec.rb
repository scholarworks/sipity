require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe CollaboratorDecorator do
      let(:sip) { Models::Collaborator.new(name: 'Hello') }
      subject { CollaboratorDecorator.new(sip) }
      it 'will have a #to_s equal its #name' do
        expect(subject.to_s).to eq(sip.name)
      end

      it 'will have a #human_attribute_name' do
        expect(subject.human_attribute_name(:name)).to eq('Name')
      end

      it 'shares .object_class with Models::Collaborator' do
        expect(CollaboratorDecorator.object_class).to eq(Models::Collaborator)
      end
    end
  end
end
