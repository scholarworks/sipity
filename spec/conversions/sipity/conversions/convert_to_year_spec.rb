require 'spec_helper'

module Sipity
  module Conversions
    describe ConvertToYear do
      include ::Sipity::Conversions::ConvertToYear

      context '#convert_to_year' do
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

        it "will return the object time's year if the object responds to #to_time" do
          time = DateTime.new(2014, 1, 23)
          object = double(to_time: time)
          expect(convert_to_year(object)).to eq(time.year)
        end

        it "will handle a string that looks like an ISO date" do
          string = "2014-12-15"
          expect(convert_to_year(string)).to eq(2014)
        end

        it "will handle a year month pair" do
          string = "June 2012"
          expect(convert_to_year(string)).to eq(2012)
        end

        it "will handle a year" do
          string = "2012"
          expect(convert_to_year(string)).to eq(2012)
        end
      end
    end
  end
end
