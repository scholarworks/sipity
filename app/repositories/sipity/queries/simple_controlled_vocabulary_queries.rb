module Sipity
  module Queries
    # Queries
    module SimpleControlledVocabularyQueries
      def get_values_by_predicate_name(name:)
        Models::SimpleControlledVocabulary.where(predicate_name: name).pluck(:predicate_value)
      end
      module_function :get_values_by_predicate_name
      public :get_values_by_predicate_name
    end
  end
end
