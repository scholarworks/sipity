require 'spec_helper'
require 'sipity/conversions/convert_to_processing_actor'
require 'cogitate/models/agent'

module Sipity
  module Conversions
    describe ConvertToProcessingActor do
      include ::Sipity::Conversions::ConvertToProcessingActor

      context '.call' do
        it 'will call the underlying conversion method' do
          object = Models::Processing::Actor.new
          expect(described_class.call(object)).to eq(object)
        end
      end

      context '.convert_to_processing_actor' do
        it 'will be private' do
          object = Models::Processing::Actor.new
          expect { described_class.convert_to_processing_actor(object) }.
            to raise_error(NoMethodError, /private method `convert_to_processing_actor'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_processing_actor' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_processing_actor)
        end

        context 'for a Models::Group' do
          context 'that is persisted' do
            let(:object) { Models::Group.create!(name: 'Hello') }
            it 'will find or create the associated Processing::Actor' do
              expect(convert_to_processing_actor(object)).to be_a(Models::Processing::Actor)
            end
          end
          context 'that is NOT persisted' do
            let(:object) { Models::Group.new }
            it 'will raise an exception' do
              expect { convert_to_processing_actor(object) }.to raise_error(Exceptions::ProcessingActorConversionError)
            end
          end
        end

        context 'for a Cogitate::Models::Agent' do
          context 'that is NOT persisted' do
            let(:object) { Cogitate::Models::Agent.build_with_identifying_information(strategy: 'netid', identifying_value: '123') }
            it 'will find or create the associated Processing::Actor' do
              expect(convert_to_processing_actor(object)).to be_a(Models::Processing::Actor)
            end
          end
        end

        context 'for a Models::User' do
          context 'that is persisted' do
            let(:object) { User.create!(username: 'hello') }
            it 'will find or create the associated Processing::Actor' do
              expect(convert_to_processing_actor(object)).to be_a(Models::Processing::Actor)
            end
          end
          context 'that is NOT persisted' do
            let(:object) { User.new }
            it 'will raise an exception' do
              expect { convert_to_processing_actor(object) }.to raise_error(Exceptions::ProcessingActorConversionError)
            end
          end
        end

        it 'will return the object if it is a Processing::Actor' do
          object = Models::Processing::Actor.new
          expect(convert_to_processing_actor(object)).to eq(object)
        end

        it 'will return the object if it responds to #to_processing_actor' do
          object = double(to_processing_actor: :actor)
          expect(convert_to_processing_actor(object)).to eq(:actor)
        end

        it 'will raise an exception if it is unhandled' do
          object = double
          expect { convert_to_processing_actor(object) }.to raise_error(Exceptions::ProcessingActorConversionError)
        end
      end
    end
  end
end
