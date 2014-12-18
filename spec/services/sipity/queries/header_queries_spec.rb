require 'rails_helper'

module Sipity
  module Commands
    # HACK: This is a cheat to get around the constraints of privatized
    # constants.
    class HeaderCommandRepository
      include HeaderCommands
    end
  end
  module Queries
    RSpec.describe HeaderQueries, type: :repository_methods do
      it 'will have a permanent URL for a given header' do
        expect(test_repository.permanent_uri_for_header_id(123)).to be_a(URI)
      end

      context '#find_headers_for' do
        # REVIEW: Crossing a boundary for this test; Is that adequate?
        let!(:command_repository) { Commands::HeaderCommandRepository.new }
        after { Commands.send(:remove_const, :HeaderCommandRepository) }
        let(:user_one) { User.new(id: 1) }
        let(:user_two) { User.new(id: 2) }
        let(:form) { test_repository.build_create_header_form(attributes: { title: 'My Title', work_publication_strategy: 'do_not_know' }) }
        let!(:header_one) { command_repository.submit_create_header_form(form, requested_by: user_one) }
        let!(:header_two) { command_repository.submit_create_header_form(form, requested_by: user_two) }
        it 'will include headers that were created by the user' do
          expect(test_repository.find_headers_for(user: user_one)).to eq([header_one])
        end
      end

      context '#assign_a_pid' do
        it 'will assign a unique permanent persisted identifier for the header'
      end

      context '#find_header' do
        it 'raises an exception if nothing is found' do
          expect { test_repository.find_header('8675309') }.to raise_error
        end
        it 'returns the Header when the object is found' do
          allow(Models::Header).to receive(:find).with('8675309').and_return(:found)
          expect(test_repository.find_header('8675309')).to eq(:found)
        end
      end

      context '#build_create_header_form' do
        it 'will build an object that can be submitted' do
          expect(test_repository.build_create_header_form).to respond_to(:submit)
        end
      end

      context '#build_update_header_form' do
        let(:header) { Models::Header.new(title: 'Hello World', id: '123') }
        it 'will raise an exception if the header is not persisted' do
          allow(header).to receive(:persisted?).and_return(false)
          expect { test_repository.build_update_header_form(header: header) }.
            to raise_error(RuntimeError)
        end

        context 'with a persisted object will return an object that' do
          before { allow(header).to receive(:persisted?).and_return(true) }
          subject { test_repository.build_update_header_form(header: header) }
          it { should respond_to :submit }
          it 'will expose an attribute of the underlying header' do
            expect(subject.title).to eq(header.title)
          end
          it 'will expose an additional attribute' do
            Models::AdditionalAttribute.create!(header: header, key: 'publisher', value: 'parmasean')
            expect(subject.publisher).to eq('parmasean')
          end
        end
      end
    end
  end
end
