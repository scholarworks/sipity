module Sip
  module DoiRunners
    # Responsible for showing the correct state of the DOI for the given SIP.
    class Show < BaseRunner
      def run(header_id: nil)
        header = repository.find_header(header_id)
        if repository.doi_already_assigned?(header)
          callback(:doi_already_assigned, header)
        elsif repository.doi_request_is_pending?(header)
          callback(:doi_request_is_pending, header)
        else
          callback(:doi_not_assigned, header)
        end
      end
    end

    # Responsible for assigning a DOI to the header.
    class Assign < BaseRunner
      def run(header_id: nil, identifier: nil)
        header = repository.find_header(header_id)
        callback(:success, header, identifier)
      end
    end
  end
end
