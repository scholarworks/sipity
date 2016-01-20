require 'sipity/guard_interface_expectation'

module Sipity
  module Forms
    module ComposableElements
      # Responsible for coordinating the Publishing and Patenting Intent; Useful
      # as an extension
      class PublishingAndPatentingIntentExtension
        def initialize(form:, repository: default_repository)
          self.form = form
          self.repository = repository
        end

        private

        attr_accessor :repository
        attr_reader :form

        include GuardInterfaceExpectation
        def form=(input)
          guard_interface_expectation!(input, :work)
          @form = input
        end

        def default_repository
          CommandRepository.new
        end

        [
          [:work_patent_strategy, :work_patent_strategies],
          [:work_publication_strategy, :work_publication_strategies]
        ].each do |singular_name, plural_name|
          module_exec do
            public

            attr_accessor singular_name, plural_name

            define_method "#{plural_name}_for_select" do
              send("possible_#{plural_name}").map(&:to_sym)
            end

            define_method "possible_#{plural_name}" do
              repository.get_controlled_vocabulary_values_for_predicate_name(name: send("#{singular_name}_predicate_name"))
            end

            define_method "#{singular_name}_from_work" do
              repository.work_attribute_values_for(work: form.work, key: send("#{singular_name}_predicate_name"), cardinality: 1)
            end

            define_method "persist_#{singular_name}" do
              repository.update_work_attribute_values!(
                work: form.work, key: send("#{singular_name}_predicate_name"), values: send(singular_name)
              )
            end

            define_method "#{singular_name}_predicate_name" do
              Models::AdditionalAttribute.const_get(singular_name.to_s.upcase)
            end
          end
        end
      end
    end
  end
end
