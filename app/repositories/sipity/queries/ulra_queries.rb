module Sipity
  module Queries
    # Queries specific to ULRA
    module UlraQueries
      def available_supervising_semester_for(ending_year: Time.zone.today.year, **)
        (-3..0).each_with_object([]) do |year_delta, values|
          year = ending_year.to_i + year_delta
          ['Spring', 'Summer', 'Fall'].each do |season|
            values << "#{season} #{year}"
          end
        end
      end
    end
  end
end
