require 'rails_helper'

module Sipity
  RSpec.describe CommandRepository, type: :repository do
    let(:query_repository_instance) { double(this_is_a_query_method: :returned_value) }
    subject { CommandRepository.new(query_repository_instance: query_repository_instance) }

    it 'will respond to the underlying query repository methods' do
      expect(subject).to respond_to(:this_is_a_query_method)
    end

    it 'will call the underlying query methods' do
      expect(subject.this_is_a_query_method).to eq(query_repository_instance.this_is_a_query_method)
    end

    it 'will be a Sipity::CommandRepository' do
      expect(subject).to be_a(Sipity::CommandRepository)
    end

    it 'will not be a Sipity::QueryRepository' do
      expect(subject).to_not be_a(Sipity::QueryRepository)
    end

    context '#submit_etd_student_submission_trigger!' do
      it 'is a placeholder until I can spend some time focusing on it' do
        expect { described_class.new.submit_etd_student_submission_trigger! }.to raise_error(NotImplementedError)
      end
    end

    context '#submit_ingest_etd' do
      it 'is a placeholder until I can spend some time focusing on it' do
        expect { described_class.new.submit_ingest_etd }.to raise_error(NotImplementedError)
      end
    end

    xit 'will not include query modules' do
      expect(Sipity::CommandRepository.included_modules.none? { |mod| mod.to_s =~ /Queries::/ }).to be_truthy
    end

    context 'verifying method definition interaction' do
      let(:modules_to_check_for_method_collision) do
        # I'm concerned about the methods I've mixed in. There are several
        # modules already included.
        Sipity::CommandRepository.included_modules.select { |mod| mod.to_s =~ /\ASipity::/ }
      end

      it 'will have unique method names for its mixed in modules' do
        # NOTE: If you are making use of module mixin sequencing and the `super`
        #   method, this spec is going to fail. And if this spec fails, you
        #   broke the build. If you need to use `super` amongst the repository
        #   modules, lets have a discussion. There is likely a way around it.
        methods_defined_in_included_modules = []

        modules_to_check_for_method_collision.each do |mod|
          public_methods = mod.public_instance_methods
          private_methods = mod.private_instance_methods
          protected_methods = mod.protected_instance_methods

          intersection_of_methods = (public_methods + private_methods + protected_methods) & methods_defined_in_included_modules
          expect(intersection_of_methods).to be_empty
          methods_defined_in_included_modules += public_methods + private_methods + protected_methods
        end
      end
    end
  end
end
