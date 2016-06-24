require "rails_helper"
require 'sipity/models/work'
require 'support/sipity/command_repository_interface'
require 'sipity/forms/work_submissions/core/copyright_form'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe CopyrightForm do
          let(:user) { double('User') }
          let(:work) { Models::Work.new(id: 1) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, requested_by: user, repository: repository, attributes: attributes } }
          let(:copyrights) do
            [double('Copyright', predicate_name: 'name', term_label: 'value', term_uri: 'code')]
          end
          subject { described_class.new(keywords) }

          before do
            allow(repository).to receive(:work_attribute_values_for).with(work: work, key: 'copyright', cardinality: 1).and_return(nil)
            allow(repository).to(
              receive(:get_controlled_vocabulary_entries_for_predicate_name).with(name: 'copyright').and_return(copyrights)
            )
          end

          its(:processing_action_name) { is_expected.to eq('copyright') }
          it { is_expected.to respond_to :copyright }

          include Shoulda::Matchers::ActiveModel
          it { is_expected.to validate_presence_of(:copyright) }
          it { is_expected.to validate_inclusion_of(:copyright).in_array(subject.available_copyrights_for_validation) }

          it 'will have #available_copyrights' do
            expect(repository).to receive(:get_controlled_vocabulary_entries_for_predicate_name).with(name: 'copyright').
              and_return(copyrights)
            expect(subject.available_copyrights).to eq(copyrights)
          end

          context '#submit' do
            let(:copyright) { 'All rights reserved' }
            let(:attributes) { { copyright: copyright } }
            subject { described_class.new(keywords) }
            before do
              allow(subject).to receive(:valid?).and_return(true)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end

            it 'will update_work_attribute_values!' do
              expect(repository).to(
                receive(:update_work_attribute_values!).with(work: work, key: 'copyright', values: copyright).and_call_original
              )
              subject.submit
            end
          end
        end
      end
    end
  end
end
