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
          work = Models::Work.create!(id: '8675309', title: "Hello")
          expect(test_repository.find_work('8675309')).to eq(work)
        end
      end

      context '#find_work_by' do
        it 'raises an exception if nothing is found' do
          expect { test_repository.find_work_by(id: '8675309') }.to raise_error
        end
        it 'returns the Work when the object is found' do
          work = Models::Work.create!(id: '8675309', title: "Hello")
          expect(test_repository.find_work_by(id: '8675309')).to eq(work)
        end
      end

      context '#build_work_submission_processing_action_form' do
        let(:parameters) { { work: double, processing_action_name: double, attributes: double } }
        let(:form) { double }
        it 'will delegate the heavy lifting to a builder' do
          expect(Forms::WorkSubmissions).to receive(:build_the_form).with(repository: test_repository, **parameters).and_return(form)
          expect(test_repository.build_work_submission_processing_action_form(parameters)).to eq(form)
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
    end
  end
end
