require 'rails_helper'

module Sip
  module Repo
    RSpec.describe HeaderMethods, type: :repository do
      let!(:klass) do
        class TestRepository
          include HeaderMethods
        end
      end
      subject { klass.new }
      after { Sip::Repo.send(:remove_const, :TestRepository) }

      context '#find_header' do
        it 'raises an exception if nothing is found' do
          expect { subject.find_header('8675309') }.to raise_error
        end

        it 'returns the Header when the object is found' do
          allow(Header).to receive(:find).with('8675309').and_return(:found)
          expect(subject.find_header('8675309')).to eq(:found)
        end

        let(:decorator) { double(decorate: :decorated) }
        it 'will build a decorated header if decoration is requested' do
          allow(Header).to receive(:find).with('8675309').and_return(:found)
          expect(subject.find_header('8675309', decorator: decorator)).to eq(:decorated)
          expect(decorator).to have_received(:decorate).with(:found)
        end
      end

      context '#submit_create_header_form' do
        let(:header) do
          subject.build_create_header_form(
            attributes: {
              title: 'This is my title',
              work_publication_strategy: 'do_not_know',
              publication_date: '2014-11-12',
              collaborators_attributes: {
                "0" => { name: "The person", role: Collaborator::DEFAULT_ROLE }
              }
            }
          )
        end
        it 'will append the publication_date if one is given' do
          expect { subject.submit_create_header_form(header) }.to(
            change { Header.count }.by(1) &&
            change { header.additional_attributes.count }.by(1) &&
            change { Collaborator.count }.by(1)
          )
        end
      end

      context '#build_create_header_form' do
        let(:decorator) { double(decorate: :decorated) }
        it 'will build a header without decoration' do
          expect(subject.build_create_header_form).to be_a(CreateHeaderForm)
        end
        it 'will build a decorated header if decoration is requested' do
          expect(subject.build_create_header_form(decorator: decorator)).to eq(:decorated)
          expect(decorator).to have_received(:decorate).with(kind_of(CreateHeaderForm))
        end
      end
    end
  end
end