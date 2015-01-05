module Sipity
  module Runners
    module DoiRunners
      # Responsible for showing the correct state of the DOI for the given SIP.
      class Show < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(sip_id:)
          sip = repository.find_sip(sip_id)
          authorization_layer.enforce!(show?: sip) do
            # TODO: Tease out state machine from DoiRecommendation
            if repository.doi_already_assigned?(sip)
              callback(:doi_already_assigned, sip)
            elsif repository.doi_request_is_pending?(sip)
              callback(:doi_request_is_pending, sip)
            else
              callback(:doi_not_assigned, sip)
            end
          end
        end
      end

      # Responsible for assigning a DOI to the sip.
      class AssignADoi < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(sip_id:, identifier: nil)
          sip = repository.find_sip(sip_id)
          form = repository.build_assign_a_doi_form(sip: sip, identifier: identifier)
          authorization_layer.enforce!(submit?: form) do
            if repository.submit_assign_a_doi_form(form, requested_by: current_user)
              # TODO: Should this be the form or the sip? Likely the form, but
              # the controller implementations assume the sip
              callback(:success, sip, form.identifier)
            else
              callback(:failure, form)
            end
          end
        end
      end

      # Responsible for requesting a DOI for the sip.
      class RequestADoi < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(sip_id:, attributes:)
          sip = repository.find_sip(sip_id)
          form = repository.build_request_a_doi_form(attributes.merge(sip: sip))
          authorization_layer.enforce!(submit?: form) do
            if repository.submit_request_a_doi_form(form, requested_by: current_user)
              # TODO: Should this be the form or the sip? Likely the form, but
              # the controller implementations assume the sip
              callback(:success, sip)
            else
              callback(:failure, form)
            end
          end
        end
      end
    end
  end
end
