module Sipity
  module Queries
    # Queries
    module SimpleControlledVocabularyQueries
      def get_controlled_vocabulary_values_for_predicate_name(name:)
        get_controlled_vocabulary_entries_for_predicate_name(name: name).pluck(:term_label)
      end

      def get_controlled_vocabulary_entries_for_predicate_name(name:)
        Models::SimpleControlledVocabulary.where(predicate_name: name)
      end

      def get_controlled_vocabulary_value_for(name:, term_uri:)
        Models::SimpleControlledVocabulary.
          where(predicate_name: name, term_uri: term_uri).
          pluck(:term_label).first || term_uri
      end
    end
  end
end
