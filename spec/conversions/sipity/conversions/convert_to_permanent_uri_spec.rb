require 'spec_helper'

module Sipity
  module Conversions
    describe ConvertToPermanentUri do
      include ::Sipity::Conversions::ConvertToPermanentUri

      context '.call' do
        it 'will call the underlying conversion method' do
          expect(described_class.call(1234)).to be_a(String)
        end
      end

      context '.convert_to_permanent_uri' do
        it 'will be private' do
          object = 1234
          expect { described_class.convert_to_permanent_uri(object) }.
            to raise_error(NoMethodError, /private method `convert_to_permanent_uri'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_permanent_uri' do
        it 'converts a decorated header' do
          object = Decorators::HeaderDecorator.decorate(Models::Header.new(id: 1234))
          expect(convert_to_permanent_uri(object)).to match(/1234\Z/)
        end

        it 'converts a header' do
          object = Models::Header.new(id: 1234)
          expect(convert_to_permanent_uri(object)).to match(/1234\Z/)
        end

        it 'converts an object related to a header' do
          object = double(header: Models::Header.new(id: 1234))
          expect(convert_to_permanent_uri(object)).to match(/1234\Z/)
        end

        it 'converts an object that has a header_id' do
          object = double(header_id: 1234)
          expect(convert_to_permanent_uri(object)).to match(/1234\Z/)
        end

        it 'converts a Fixnum object (at least until we change that scheme)' do
          object = 1234
          expect(convert_to_permanent_uri(object)).to match(/1234\Z/)
        end

        it 'will raise an exception if the input is not convertable' do
          object = :hello
          expect { convert_to_permanent_uri(object) }.to raise_error(Exceptions::PermanentUriConversionError)
        end

        it 'will raise an exception if the input is not present' do
          object = ''
          expect { convert_to_permanent_uri(object) }.to raise_error(Exceptions::PermanentUriConversionError)
        end
      end
    end
  end
end
