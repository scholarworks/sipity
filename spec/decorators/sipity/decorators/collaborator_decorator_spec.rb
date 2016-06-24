require "rails_helper"
require 'sipity/decorators/collaborator_decorator'

module Sipity
  module Decorators
    RSpec.describe CollaboratorDecorator do
      let(:work) { Models::Collaborator.new(name: 'Hello') }
      subject { CollaboratorDecorator.new(work) }
      it 'will have a #to_s equal its #name' do
        expect(subject.to_s).to eq(work.name)
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
