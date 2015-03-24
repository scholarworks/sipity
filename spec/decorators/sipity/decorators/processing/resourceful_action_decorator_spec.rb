require 'spec_helper'

module Sipity
  module Decorators
    module Processing
      RSpec.describe ResourcefulActionDecorator do
        ENTITY_ID = '1234'
        let(:entity) { Models::Work.new(id: ENTITY_ID) }
        let(:user) { double }

        it 'will not initialize with an invalid action name' do
          action = double(name: 'bob')
          expect { described_class.new(action: action, entity: entity, user: user) }.to raise_error(Exceptions::UnprocessableResourcefulActionNameError)
        end

        [
          { name: 'show', expected_path: "/works/#{ENTITY_ID}", button_class: 'btn-primary' },
          { name: 'new', expected_path: "/works/new", button_class: 'btn-primary' },
          { name: 'create', expected_path: "/works/new", button_class: 'btn-primary' },
          { name: 'edit', expected_path: "/works/#{ENTITY_ID}/edit", button_class: 'btn-primary' },
          { name: 'update', expected_path: "/works/#{ENTITY_ID}/edit", button_class: 'btn-primary' },
          { name: 'destroy', expected_path: "/works/#{ENTITY_ID}", button_class: 'btn-danger' }
        ].each_with_index do |example, index|
          it "will have a path #{example[:expected_path].inspect} for action name #{example[:name].inspect} (Scenario ##{index})" do
            action = double(name: example.fetch(:name))
            subject = described_class.new(action: action, entity: entity, user: user)
            expect(subject.path).to eq(example.fetch(:expected_path))
          end

          it "will have a button_class #{example[:button_class].inspect} for action name #{example[:name].inspect} (Scenario ##{index})" do
            action = double(name: example.fetch(:name))
            subject = described_class.new(action: action, entity: entity, user: user)
            expect(subject.button_class).to eq(example.fetch(:button_class))
          end

        end

        it 'will render an entry point with data-method="delete" for :destroy action' do
          action = double(name: 'destroy')
          subject = described_class.new(action: action, entity: entity, user: user)
          expect(subject.render_entry_point).to have_tag('.action[itemprop="target"][itemtype="http://schema.org/EntryPoint"]') do
            with_tag("a[data-method='delete'][href='#{subject.path}']")
          end
        end

        it 'will render an entry point with data-method="delete" for :destroy action' do
          action = double(name: 'edit')
          subject = described_class.new(action: action, entity: entity, user: user)
          expect(subject.render_entry_point).to have_tag('.action[itemprop="target"][itemtype="http://schema.org/EntryPoint"]') do
            with_tag("a[href='#{subject.path}']")
          end
        end
      end
    end
  end
end
