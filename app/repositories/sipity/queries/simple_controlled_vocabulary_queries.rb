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
    end
  end
end
