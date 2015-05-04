require 'spec_helper'

module Sipity
  module Controllers
    module WorkAreas
      RSpec.describe ResourcefulActionPresenter, type: :presenter do
        let(:context) do
          PresenterHelper::Context.new(view_object: view_object, current_user: current_user, resourceful_action: resourceful_action)
        end
        let(:current_user) { double('Current User') }
        let(:view_object) { Models::WorkArea.new(slug: 'the-slug') }
        let(:resourceful_action) { Models::Processing::StrategyAction.new(name: 'show') }
        subject { described_class.new(context, resourceful_action: resourceful_action, view_object: view_object) }

        it "will have a path based on the work area query action" do
          expect(subject.path).to eq("/areas/#{view_object.slug}/do/#{resourceful_action.name}")
        end

        context '#render_entry_point' do
          it 'will render an entry point with data-method="delete" for :destroy action' do
            resourceful_action = double(name: 'destroy')
            subject = described_class.new(context, resourceful_action: resourceful_action, view_object: view_object)
            expect(subject.render_entry_point).to have_tag('.action[itemprop="target"][itemtype="http://schema.org/EntryPoint"]') do
              with_tag("a[data-method='delete'][href='#{subject.path}']")
            end
          end

          it 'will render an entry point link for an available action' do
            resourceful_action = double(name: 'edit')
            subject = described_class.new(context, resourceful_action: resourceful_action, view_object: view_object)
            expect(subject.render_entry_point).to have_tag('.action[itemprop="target"][itemtype="http://schema.org/EntryPoint"]') do
              with_tag("a[href='#{subject.path}']")
            end
          end

          it 'will not render an entry point link when an action is not avaialble' do
            resourceful_action = double(name: 'edit')
            subject = described_class.new(context, resourceful_action: resourceful_action, view_object: view_object)
            expect(subject).to receive(:available?).and_return(false)
            expect(subject.render_entry_point).to have_tag('.action[itemprop="target"][itemtype="http://schema.org/EntryPoint"]') do
              with_tag("meta[itemprop='name'][content='#{resourceful_action.name}']")
              without_tag("a[href='#{subject.path}']")
            end
          end
        end
      end
    end
  end
end
