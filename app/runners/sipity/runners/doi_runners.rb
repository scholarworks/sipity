module Sipity
  module Runners
    module DoiRunners
      # Responsible for showing the correct state of the DOI for the given SIP.
      class Show < BaseRunner
        self.requires_authentication = true

        def run(header_id: nil)
          header = repository.find_header(header_id)
          with_authorization_enforcement(:show?, header) do
            # TODO: Tease out state machine from DoiRecommendation
            if repository.doi_already_assigned?(header)
              callback(:doi_already_assigned, header)
            elsif repository.doi_request_is_pending?(header)
              callback(:doi_request_is_pending, header)
            else
              callback(:doi_not_assigned, header)
            end
          end
        end
      end

      # Responsible for assigning a DOI to the header.
      class AssignADoi < BaseRunner
        self.requires_authentication = true

        def run(header_id: nil, identifier: nil)
          header = repository.find_header(header_id)
          form = repository.build_assign_a_doi_form(header: header, identifier: identifier)
          with_authorization_enforcement(:submit?, form) do
            if repository.submit_assign_a_doi_form(form)
              # TODO: Should this be the form or the header? Likely the form, but
              # the controller implementations assume the header
              callback(:success, header, form.identifier)
            else
              callback(:failure, form)
            end
          end
        end
      end

      # Responsible for requesting a DOI for the header.
      class RequestADoi < BaseRunner
        self.requires_authentication = true

        def run(header_id:, attributes:)
          header = repository.find_header(header_id)
          form = repository.build_request_a_doi_form(attributes.merge(header: header))
          with_authorization_enforcement(:submit?, form) do
            if repository.submit_request_a_doi_form(form)
              # TODO: Should this be the form or the header? Likely the form, but
              # the controller implementations assume the header
              callback(:success, header)
            else
              callback(:failure, form)
            end
          end
        end
      end
    end
  end
end
