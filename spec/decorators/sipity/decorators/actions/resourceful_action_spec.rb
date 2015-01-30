require 'spec_helper'

module Sipity
  module Decorators
    module Actions
      RSpec.describe ResourcefulAction do
        let(:name) { 'show' }
        let(:entity) { double('Entity', to_param: '1234') }

        context 'default behavior' do
          subject { described_class.new(name: name, entity: entity) }
          its(:view_context) { should be_present }
        end

        subject { described_class.new(name: name, entity: entity) }
        its(:availability_state) { should eq('available') }
        its(:available?) { should eq(true) }

        [
          { name: 'show', expected_path: "/works/1234" },
          { name: 'new', expected_path: "/works/new" },
          { name: 'create', expected_path: "/works/new" },
          { name: 'edit', expected_path: "/works/1234/edit" },
          { name: 'update', expected_path: "/works/1234/edit" },
          { name: 'destroy', expected_path: "/works/1234" }
        ].each_with_index do |example, index|
          it "will have a path #{example[:expected_path].inspect} for action name #{example[:name].inspect}" do
            subject = described_class.new(name: example.fetch(:name), entity: entity)
            expect(subject.path).to eq(example.fetch(:expected_path))
          end
        end

        it 'will fail to initialize if we have an unknown resource action name' do
          expect { described_class.new(name: '__unknown__', entity: entity) }.
            to raise_error(Exceptions::UnprocessableResourcefulActionNameError)
        end
      end
    end
  end
end
