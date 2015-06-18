module Sipity
  module Queries
    # Queries
    module SimpleControlledVocabularyQueries
      def get_controlled_vocabulary_values_for_predicate_name(name:)
        Locabulary.active_labels_for(predicate_name: name)
      end

      def get_controlled_vocabulary_entries_for_predicate_name(name:)
        Locabulary.active_items_for(predicate_name: name)
      end

      def get_controlled_vocabulary_value_for(name:, term_uri:)
        Locabulary.active_label_for_uri(predicate_name: name, term_uri: term_uri)
      end
    end
  end
end
