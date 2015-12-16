require 'sipity/models/additional_attribute'
require 'active_support/core_ext/numeric/time'

module Sipity
  module ProcessingHooks
    module Etd
      module Works
        # Responsible for performing any additional behavior as part of a user
        # taking the SubmitForReview action on an ETD Work.
        module GradSchoolSignoffProcessingHook
          module_function

          # When the GradSchoolSignoff action is taken on a given ETD Work,
          # this method should be called.
          #
          # @api private
          # @see Sipity::ProcessingHooks.call for how this is called
          def call(entity:, repository: default_repository, as_of_date: default_as_of_date, **_keywords)
            work = entity.proxy_for
            repository.update_work_attribute_values!(
              work: work,
              values: as_of_date.strftime(Models::AdditionalAttribute::DATE_FORMAT),
              key: Models::AdditionalAttribute::ETD_REVIEWER_SIGNOFF_DATE
            )
          end

          def default_repository
            require 'sipity/command_repository' unless defined?(Sipity::CommandRepository)
            CommandRepository.new
          end
          private_class_method :default_repository

          def default_as_of_date
            require 'active_support/core_ext/numeric/time' unless Time.respond_to?(:zone)
            Time.zone.today
          end
          private_class_method :default_as_of_date
        end
      end
    end
  end
end
