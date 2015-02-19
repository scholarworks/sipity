module Sipity
  module Runners
    module DoiRunners
      # Responsible for showing the correct state of the DOI for the given SIP.
      class Show < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :show?

        def run(work_id:)
          work = repository.find_work(work_id)
          authorization_layer.enforce!(action_name => work) do
            # TODO: Tease out state machine from DoiRecommendation
            if repository.doi_already_assigned?(work)
              callback(:doi_already_assigned, work)
            elsif repository.doi_request_is_pending?(work)
              callback(:doi_request_is_pending, work)
            else
              callback(:doi_not_assigned, work)
            end
          end
        end
      end

      # Responsible for assigning a DOI to the work.
      class AssignADoi < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :submit?

        def run(work_id:, identifier: nil)
          work = repository.find_work(work_id)
          form = repository.build_assign_a_doi_form(work: work, identifier: identifier)
          authorization_layer.enforce!(action_name => form) do
            if repository.submit_assign_a_doi_form(form, requested_by: current_user)
              # TODO: Should this be the form or the work? Likely the form, but
              # the controller implementations assume the work
              callback(:success, work, form.identifier)
            else
              callback(:failure, form)
            end
          end
        end
      end

      # Responsible for requesting a DOI for the work.
      class RequestADoi < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default
        self.action_name = :submit?

        def run(work_id:, attributes:)
          work = repository.find_work(work_id)
          form = repository.build_request_a_doi_form(attributes.merge(work: work))
          authorization_layer.enforce!(action_name => form) do
            if repository.submit_request_a_doi_form(form, requested_by: current_user)
              # TODO: Should this be the form or the work? Likely the form, but
              # the controller implementations assume the work
              callback(:success, work)
            else
              callback(:failure, form)
            end
          end
        end
      end
    end
  end
end
