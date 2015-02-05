module Sipity
  module Runners
    module WorkEnrichmentRunners
      # Responsible for responding with the correct form for the work's description
      class Edit < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_id:, enrichment_type:)
          work = repository.find_work(work_id)
          decorated_work = Decorators::WorkDecorator.decorate(work)
          form = repository.build_enrichment_form(work: decorated_work, enrichment_type: enrichment_type)
          authorization_layer.enforce!(submit?: form) do
            callback(:success, form)
          end
        end
      end

      # Responsible for updating an enrichment
      class Update < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_id:, enrichment_type:, attributes:)
          work = repository.find_work(work_id)
          decorated_work = Decorators::WorkDecorator.decorate(work)
          form = repository.build_enrichment_form(attributes.merge(work: decorated_work, enrichment_type: enrichment_type))
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
