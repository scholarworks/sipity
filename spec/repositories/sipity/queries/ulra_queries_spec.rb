require 'spec_helper'
require 'sipity/queries/ulra_queries'

RSpec.describe Sipity::Queries::UlraQueries, type: :isolated_repository_module do
  let(:work) { Sipity::Models::Work.new(id: 1) }
  let(:another_work) { Sipity::Models::Work.new(id: 2) }
  context '#possible_expected_graduation_terms' do
    it 'will return an array of semesters' do
      expect(test_repository.possible_expected_graduation_terms(ending_year: 2015, work: work)).to eq(
        [
          "Spring 2014", "Summer 2014", "Fall 2014",
          "Spring 2015", "Summer 2015", "Fall 2015",
          "Spring 2016", "Summer 2016", "Fall 2016",
          "Spring 2017", "Summer 2017", "Fall 2017",
          "Spring 2018", "Summer 2018", "Fall 2018"
        ]
      )
    end
  end
end
