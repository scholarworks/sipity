module Sip
  module DoiRunners
    # Responsible for showing the correct state of the DOI for the given SIP.
    class Show < BaseRunner
      def run(header_id: nil)
        header = repository.find_header(header_id)
        # recommendation = repository.doi_recommendation_for(header)
        # callback(recommendation.state, recommendation.header)
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
        form = repository.build_header_doi_form(header: header, identifier: identifier)
        response = form.submit do |f|
          repository.create_additional_attribute(header: f.header, key: f.identifier_key, value: f.identifier)
        end
        if response
          callback(:success, header, form.identifier)
        else
          callback(:failure, form)
        end
      end
    end
  end
end
