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

    # Responsible for building, validating, and submitting the form.
    class Create < BaseRunner
      def run(header_id:, attributes: {})
        header = repository.find_header(header_id)
        form = repository.build_assign_a_citation_form(attributes.merge(header: header))
        if repository.submit_assign_a_citation_form(form)
          callback(:success, header)
        else
          callback(:failure, form)
        end
      end
    end
  end
end