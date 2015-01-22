require 'rails_helper'

module Sipity
  module Commands
    # HACK: This is a cheat to get around the constraints of privatized
    # constants.
    class WorkCommandRepository
      include WorkCommands
    end
  end
  module Queries
    RSpec.describe WorkQueries, type: :repository_methods do
      it 'will have a permanent URL for a given work' do
        expect(test_repository.permanent_uri_for_work_id(123)).to be_a(URI)
      end

      context '#find_works_for' do
        # REVIEW: Crossing a boundary for this test; Is that adequate?
        let!(:command_repository) { Commands::WorkCommandRepository.new }
        after { Commands.send(:remove_const, :WorkCommandRepository) }
        let(:user_one) { User.new(id: 1, username: 'user_one') }
        let(:user_two) { User.new(id: 2, username: 'user_two') }
        let(:form) do
          test_repository.build_create_work_form(
            attributes: { title: 'My Title', work_publication_strategy: 'do_not_know', work_type: 'etd' }
          )
        end
        let!(:work_one) { form.submit(repository: Sipity::Repository.new, requested_by: user_one) }
        let!(:work_two) { form.submit(repository: Sipity::Repository.new, requested_by: user_two) }
        it 'will include works that were created by the user' do
          expect(test_repository.find_works_for(user: user_one)).to eq([work_one])
        end
      end

      context '#assign_a_pid' do
        it 'will assign a unique permanent persisted identifier for the work'
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

      context '#build_create_work_form' do
        it 'will build an object that can be submitted' do
          expect(test_repository.build_create_work_form).to respond_to(:submit)
        end
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
