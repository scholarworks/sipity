module Sipity
  module Queries
    # Queries
    module SimpleControlledVocabularyQueries
      def get_controlled_vocabulary_values_for_predicate_name(name:)
        get_controlled_vocabulary_entries_for_predicate_name(name: name).pluck(:predicate_value)
      end

      def get_controlled_vocabulary_entries_for_predicate_name(name:)
        Models::SimpleControlledVocabulary.where(predicate_name: name).order(:predicate_value)
      end

      def get_controlled_vocabulary_value_for(name:, predicate_value_code:)
        Models::SimpleControlledVocabulary.
          where(predicate_name: name, predicate_value_code: predicate_value_code).
          pluck(:predicate_value).first || predicate_value_code
      end
    end
  end
end
