require "rails_helper"
require 'sipity/conversions/convert_to_year'

module Sipity
  module Conversions
    describe ConvertToYear do
      include ::Sipity::Conversions::ConvertToYear

      context '.call' do
        it 'will call the underlying conversion method' do
          object = double(to_year: 1234)
          expect(described_class.call(object)).to eq(object.to_year)
        end
      end

      context '.convert_to_year' do
        it 'will be private' do
          object = double(to_year: 1234)
          expect { described_class.convert_to_year(object) }.to raise_error(NoMethodError, /private method `convert_to_year'/)
        end
      end

      context '#call' do
        it 'will not be implemented' do
          expect(self).to_not respond_to(:call)
        end
      end

      context '#convert_to_year' do

        it 'will be a private instance method' do
          expect(self.class.private_instance_methods).to include(:convert_to_year)
        end

        it "will return the object's year if the object responds to #year" do
          object = double(year: 1234)
          expect(convert_to_year(object)).to eq(object.year)
        end

        it "will return the object's to_year if the object responds to #to_year" do
          object = double(to_year: 1234)
          expect(convert_to_year(object)).to eq(object.to_year)
        end

        it "will return the object date's year if the object responds to #to_date" do
          date = Date.civil(2014, 1, 23)
          object = double(to_date: date)
          expect(convert_to_year(object)).to eq(date.year)
        end

        it "will handle a string that looks like an ISO date" do
          string = "2014-12-15"
          expect(convert_to_year(string)).to eq(2014)
        end

        it "will handle a year month pair" do
          string = "June 2012"
          expect(convert_to_year(string)).to eq(2012)
        end

        it "will handle a year as a string" do
          string = "2012"
          expect(convert_to_year(string)).to eq(2012)
        end

        it "will handle an integer" do
          string = 2012
          expect(convert_to_year(string)).to eq(2012)
        end
      end
    end
  end
end
