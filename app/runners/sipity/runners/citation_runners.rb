module Sipity
  module Runners
    module CitationRunners
      # Responsible for responding with the state of the work's citation.
      class Show < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_id:)
          work = repository.find_work(work_id)
          authorization_layer.enforce!(show?: work) do
            if repository.citation_already_assigned?(work)
              callback(:citation_assigned, work)
            else
              callback(:citation_not_assigned, work)
            end
          end
        end
      end

      # Responsible for responding with the correct form for the work's citation
      class New < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_id:)
          work = repository.find_work(work_id)
          form = repository.build_assign_a_citation_form(work: work)
          authorization_layer.enforce!(submit?: form) do
            if repository.citation_already_assigned?(work)
              callback(:citation_assigned, work)
            else
              callback(:citation_not_assigned, form)
            end
          end
        end
      end

      # Responsible for building, validating, and submitting the form.
      class Create < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_id:, attributes: {})
          work = repository.find_work(work_id)
          form = repository.build_assign_a_citation_form(attributes.merge(work: work))
          authorization_layer.enforce!(submit?: form) do
            if form.submit(repository: repository, requested_by: current_user)
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
