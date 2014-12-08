require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe CollaboratorDecorator do
      let(:header) { Models::Collaborator.new(name: 'Hello') }
      subject { CollaboratorDecorator.new(header) }
      it 'will have a #to_s equal its #name' do
        expect(subject.to_s).to eq(header.name)
      end

      it 'will have a #human_attribute_name' do
        expect(subject.human_attribute_name(:name)).to eq('Name')
      end
    end
  end
end
