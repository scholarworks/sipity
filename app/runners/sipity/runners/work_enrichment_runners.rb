module Sipity
  module Runners
    module WorkEnrichmentRunners
      # Responsible for responding with the correct form for the work's description
      class Edit < BaseRunner
        self.authentication_layer = :default
        self.authorization_layer = :default

        def run(work_id:, enrichment_type:)
          work = repository.find_work(work_id)
          form = repository.build_enrichment_form(work: work, enrichment_type: enrichment_type)
          authorization_layer.enforce!(submit?: form) do
            callback(:success, form)
          end
        end
      end
    end
  end
end
