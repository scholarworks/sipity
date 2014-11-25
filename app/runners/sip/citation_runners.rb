module Sip
  module CitationRunners
    # Responsible for responding with the state of the header's citation.
    class Show < BaseRunner
      def run(header_id:)
        header = repository.find_header(header_id)
        callback(:citation_not_assigned, header)
      end
    end

    # Responsible for responding with the correct form for the header's citation
    class New < BaseRunner
      def run(header_id:)
        header = repository.find_header(header_id)
        form = repository.build_assign_a_citation_form(header: header)
        callback(:citation_not_assigned, form)
      end
    end
  end
end
