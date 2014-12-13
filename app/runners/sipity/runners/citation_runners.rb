module Sipity
  module Runners
    module CitationRunners
      # Responsible for responding with the state of the header's citation.
      class Show < BaseRunner
        self.requires_authentication = true
        self.enforces_authorization = true

        def run(header_id:)
          header = repository.find_header(header_id)
          authorization_layer.enforce!(show?: header) do
            if repository.citation_already_assigned?(header)
              callback(:citation_assigned, header)
            else
              callback(:citation_not_assigned, header)
            end
          end
        end
      end

      # Responsible for responding with the correct form for the header's citation
      class New < BaseRunner
        self.requires_authentication = true
        self.enforces_authorization = true

        def run(header_id:)
          header = repository.find_header(header_id)
          form = repository.build_assign_a_citation_form(header: header)
          authorization_layer.enforce!(submit?: form) do
            if repository.citation_already_assigned?(header)
              callback(:citation_assigned, header)
            else
              callback(:citation_not_assigned, form)
            end
          end
        end
      end

      # Responsible for building, validating, and submitting the form.
      class Create < BaseRunner
        self.requires_authentication = true
        self.enforces_authorization = true

        def run(header_id:, attributes: {})
          header = repository.find_header(header_id)
          form = repository.build_assign_a_citation_form(attributes.merge(header: header))
          authorization_layer.enforce!(submit?: form) do
            if repository.submit_assign_a_citation_form(form, requested_by: current_user)
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
