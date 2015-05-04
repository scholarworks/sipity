require 'spec_helper'

module Sipity
  module Controllers
    RSpec.describe ResourcefulActionPresenter, type: :presenter do
      let(:context) do
        PresenterHelper::Context.new(current_user: current_user, resourceful_action: resourceful_action)
      end
      let(:current_user) { double('Current User') }
      let(:resourceful_action) { Models::Processing::StrategyAction.new(name: 'show') }
      subject { described_class.new(context, resourceful_action: resourceful_action) }

      it "will require you to implement a path" do
        expect { subject.path }.to raise_error(NotImplementedError)
      end

      context 'with a defined path' do
        before do
          allow(subject).to receive(:path).and_return('/hello/world')
        end

        context '#render_entry_point' do
          context 'for :destroy action' do
            let(:resourceful_action) { double(name: 'destroy') }
            it 'will render an entry point with data-method="delete"' do
              expect(subject.render_entry_point).to have_tag('.action[itemprop="target"][itemtype="http://schema.org/EntryPoint"]') do
                with_tag("a[data-method='delete'][href='#{subject.path}']")
              end
            end
          end

          context 'for an available (non :destroy) action' do
            let(:resourceful_action) { double(name: 'edit') }
            it 'will render an entry point link for an available action' do
              expect(subject.render_entry_point).to have_tag('.action[itemprop="target"][itemtype="http://schema.org/EntryPoint"]') do
                with_tag("a[href='#{subject.path}']")
              end
            end
          end

          context 'for an unavailable action' do
            let(:resourceful_action) { double(name: 'edit') }
            it 'will not render an entry point link' do
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
end
