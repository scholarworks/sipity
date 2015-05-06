require 'rails_helper'

module Sipity
  module Queries
    RSpec.describe WorkQueries, type: :isolated_repository_module do
      context '#find_works_for' do
        it 'will delegate to Policies::WorkPolicy::Scope' do
          user = double
          expect(Policies::WorkPolicy::Scope).to receive(:resolve)
          test_repository.find_works_for(user: user)
        end
      end

      context '#find_work' do
        it 'raises an exception if nothing is found' do
          expect { test_repository.find_work('8675309') }.to raise_error
        end
        it 'returns the Work when the object is found' do
          allow(Models::Work).to receive(:find).with('8675309').and_return(:found)
          expect(test_repository.find_work('8675309')).to eq(:found)
        end
      end

      context '#work_access_right_codes' do
        let(:work) { Models::Work.new(title: 'Hello World', id: '123') }
        it 'will expose access_right_code of the underlying work' do
          Models::AccessRight.create!(entity: work, access_right_code: 'private_access')
          expect(test_repository.work_access_right_codes(work: work)).to eq(['private_access'])
        end
      end

      context '#build_create_work_form' do
        it 'will build an ETD based form (note this may be delegated to a generalized form builder)' do
          expect(Forms::Etd::StartASubmissionForm).to receive(:new).with(repository: test_repository, title: 'title')
          test_repository.build_create_work_form(attributes: { title: 'title' })
        end
      end

      context '#build_dashboard_view' do
        let(:user) { double }
        let(:filter) { double }
        subject { test_repository.build_dashboard_view(user: user, filter: filter) }
        it { should respond_to :filterable_processing_states }
        it { should respond_to :search_path }
      end

      context '#build_update_work_form' do
        let(:work) { Models::Work.new(title: 'Hello World', id: '123') }
        it 'will raise an exception if the work is not persisted' do
          allow(work).to receive(:persisted?).and_return(false)
          expect { test_repository.build_update_work_form(work: work) }.
            to raise_error(RuntimeError)
        end

        context 'with a persisted object will return an object that' do
          before { allow(work).to receive(:persisted?).and_return(true) }
          subject { test_repository.build_update_work_form(work: work) }
          it { should respond_to :submit }
          it 'will expose an attribute of the underlying work' do
            expect(subject.title).to eq(work.title)
          end
          it 'will expose an additional attribute' do
            Models::AdditionalAttribute.create!(work: work, key: 'publisher', value: 'parmasean')
            expect(subject.publisher).to eq('parmasean')
          end
        end
      end
    end
  end
end
