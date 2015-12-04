require 'spec_helper'
require 'sipity/queries/ulra_queries'

RSpec.describe Sipity::Queries::UlraQueries, type: :isolated_repository_module do
  let(:work) { Sipity::Models::Work.new(id: 1) }
  let(:another_work) { Sipity::Models::Work.new(id: 2) }
  context '#available_supervising_semester_for' do
    it 'will return an array of semesters' do
      expect(test_repository.available_supervising_semester_for(ending_year: 2015, work: work)).to eq(
        [
          "Spring 2012", "Summer 2012", "Fall 2012",
          "Spring 2013", "Summer 2013", "Fall 2013",
          "Spring 2014", "Summer 2014", "Fall 2014",
          "Spring 2015", "Summer 2015", "Fall 2015"
        ]
      )
    end
  end
end
