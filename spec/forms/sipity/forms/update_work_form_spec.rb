require 'spec_helper'

module Sipity
  module Forms
    RSpec.describe UpdateWorkForm do
      let(:work) { double('Work') }
      subject do
        described_class.new(
          work: work, exposed_attribute_names: [:title],
          attributes: { title: 'My Title', not_exposed: 'Not Exposed' }
        )
      end

      its(:policy_enforcer) { should eq Policies::EnrichWorkByFormSubmissionPolicy }
      its(:to_model) { should eq(work) }

      it 'will have a model_name that is the same as the Models::Work.model_name' do
        expect(described_class.model_name).to eq(Models::Work.model_name)
      end

      context 'exposing an attribute_name that is an already defined method' do
        it 'will raise an exception' do
          expect { described_class.new(work: work, exposed_attribute_names: [:submit]) }.
            to raise_error(Exceptions::ExistingMethodsAlreadyDefined)
        end
      end

      context 'when no attribute_names are exposed' do
        it 'will NOT raise an exception' do
          expect { described_class.new(work: work, exposed_attribute_names: []) }.
            to_not raise_error
        end
      end

      context 'for an exposed attribute' do
        it 'will respond to that attribute name' do
          expect(subject).to respond_to(:title)
        end
        it 'will expose a getter for the attribute' do
          expect(subject.title).to eq 'My Title'
        end
        it 'will expose a getter via :send' do
          expect(subject.send(:title)).to eq('My Title')
        end
        it 'will expose the named attribute' do
          expect(subject.exposes?(:title)).to eq(true)
        end
      end

      context 'for an attribute that is not an exposed attribute' do
        it 'will NOT respond to that attribute name' do
          expect(subject).to_not respond_to(:not_exposed)
        end
        it 'will NOT expose a getter for the attribute' do
          expect { subject.not_exposed }.to raise_error NoMethodError
        end
        it 'will NOT expose a getter via :send' do
          expect { subject.send(:not_exposed) }.to raise_error NoMethodError
        end
        it 'will NOT expose the named attribute' do
          expect(subject.exposes?(:not_exposed)).to eq(false)
        end
      end

      context '#submit' do
        # TODO: Make sure the repository is receiving the messages but don't worry about checking
        #   are changes being made.
        let(:user) { User.new(id: '123') }
        let(:work) { Models::Work.create(title: 'My Title', work_publication_strategy: 'do_not_know') }
        let(:repository) { Sipity::Repository.new }
        let(:form) { repository.build_update_work_form(work: work, attributes: { title: 'My New Title', publisher: 'new publisher' }) }
        context 'with invalid data' do
          before do
            allow(work).to receive(:persisted?).and_return(true)
            allow(form).to receive(:valid?).and_return(false)
          end
          it 'will return false' do
            expect(form.submit(repository: repository, requested_by: user)).to eq(false)
          end
          it 'will NOT update the work' do
            expect { form.submit(repository: repository, requested_by: user) }.
              to_not change { work.reload.title }
          end
        end
        context 'with valid data' do
          before do
            # TODO: Remove the dependency on creating the item.
            Models::AdditionalAttribute.create!(work: work, key: 'publisher', value: 'parmasean')
            allow(work).to receive(:persisted?).and_return(true)
            allow(form).to receive(:valid?).and_return(true)
          end
          it 'will return the work after updating the work, additional attributes, and creating an event log entry' do
            expect(work).to receive(:update).with(title: 'My New Title', work_publication_strategy: 'do_not_know')
            expect(repository).to receive(:update_work_attribute_values!).with(work: work, key: 'publisher', values: 'new publisher')
            expect(repository).to receive(:log_event!).with(entity: work, user: user, event_name: 'update_work_form/submit')
            response = form.submit(repository: repository, requested_by: user)
            expect(response).to eq(work)
          end
        end
      end
    end
  end
end
