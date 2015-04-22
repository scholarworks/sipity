module Sipity
  module Queries
    # Queries related to work areas.
    module WorkAreaQueries
      def find_work_area_by(slug:)
        Models::WorkArea.where(slug: slug).first!
      end
    end
  end
end
