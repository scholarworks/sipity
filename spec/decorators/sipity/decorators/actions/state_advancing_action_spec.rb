require 'spec_helper'

module Sipity
  module Decorators
    module Actions
      RSpec.describe StateAdvancingAction do
        let(:name) { 'hello_world' }
        let(:entity) { double('Entity', to_param: '12') }
        let(:todo_is_done?) { nil }
        let(:repository) { double('Repository', are_all_of_the_required_todo_items_done_for_work?: todo_is_done?) }

        context 'default behavior' do
          subject { described_class.new(name: name, entity: entity) }
          its(:repository) { should respond_to(:are_all_of_the_required_todo_items_done_for_work?) }
          its(:view_context) { should be_present }
        end

        subject { described_class.new(name: name, entity: entity, repository: repository) }
        context 'when all required todo items are done' do
          let(:todo_is_done?) { true }
          its(:availability_state) { should eq('available') }
          its(:available?) { should eq(true) }
          its(:path) { should eq("/works/#{entity.to_param}/trigger/#{name}") }
        end
        context 'when NOT all of the required todo items are done' do
          let(:todo_is_done?) { false }
          its(:availability_state) { should == 'unavailable' }
          its(:available?) { should == false }
          its(:path) { should eq("/works/#{entity.to_param}/trigger/#{name}") }
        end
      end
    end
  end
end
