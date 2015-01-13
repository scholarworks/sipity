require 'rails_helper'

module Sipity
  module Commands
    # HACK: This is a cheat to get around the constraints of privatized
    # constants.
    class SipCommandRepository
      include SipCommands
    end
  end
  module Queries
    RSpec.describe SipQueries, type: :repository_methods do
      it 'will have a permanent URL for a given sip' do
        expect(test_repository.permanent_uri_for_sip_id(123)).to be_a(URI)
      end

      context '#find_sips_for' do
        # REVIEW: Crossing a boundary for this test; Is that adequate?
        let!(:command_repository) { Commands::SipCommandRepository.new }
        after { Commands.send(:remove_const, :SipCommandRepository) }
        let(:user_one) { User.new(id: 1) }
        let(:user_two) { User.new(id: 2) }
        let(:form) do
          test_repository.build_create_sip_form(
            attributes: { title: 'My Title', work_publication_strategy: 'do_not_know', work_type: 'ETD' }
          )
        end
        let!(:sip_one) { command_repository.submit_create_sip_form(form, requested_by: user_one) }
        let!(:sip_two) { command_repository.submit_create_sip_form(form, requested_by: user_two) }
        it 'will include sips that were created by the user' do
          expect(test_repository.find_sips_for(user: user_one)).to eq([sip_one])
        end
      end

      context '#assign_a_pid' do
        it 'will assign a unique permanent persisted identifier for the sip'
      end

      context '#find_sip' do
        it 'raises an exception if nothing is found' do
          expect { test_repository.find_sip('8675309') }.to raise_error
        end
        it 'returns the Sip when the object is found' do
          allow(Models::Sip).to receive(:find).with('8675309').and_return(:found)
          expect(test_repository.find_sip('8675309')).to eq(:found)
        end
      end

      context '#build_create_sip_form' do
        it 'will build an object that can be submitted' do
          expect(test_repository.build_create_sip_form).to respond_to(:submit)
        end
      end

      context '#build_update_sip_form' do
        let(:sip) { Models::Sip.new(title: 'Hello World', id: '123') }
        it 'will raise an exception if the sip is not persisted' do
          allow(sip).to receive(:persisted?).and_return(false)
          expect { test_repository.build_update_sip_form(sip: sip) }.
            to raise_error(RuntimeError)
        end

        context 'with a persisted object will return an object that' do
          before { allow(sip).to receive(:persisted?).and_return(true) }
          subject { test_repository.build_update_sip_form(sip: sip) }
          it { should respond_to :submit }
          it 'will expose an attribute of the underlying sip' do
            expect(subject.title).to eq(sip.title)
          end
          it 'will expose an additional attribute' do
            Models::AdditionalAttribute.create!(sip: sip, key: 'publisher', value: 'parmasean')
            expect(subject.publisher).to eq('parmasean')
          end
        end
      end
    end
  end
end
