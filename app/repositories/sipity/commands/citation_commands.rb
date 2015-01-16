module Sipity
  # :nodoc:
  module Commands
    # Commands
    module CitationCommands
      # REVIEW: Does this method even make sense?
      def submit_assign_a_citation_form(form, requested_by:)
        form.submit(repository: self, requested_by: requested_by)
      end
    end
    private_constant :CitationCommands
  end
end
