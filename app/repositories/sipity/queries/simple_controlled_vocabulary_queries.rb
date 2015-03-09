module Sipity
  module Queries
    # Queries
    module SimpleControlledVocabularyQueries
      def get_controlled_vocabulary_values_for_predicate_name(name:)
        Models::SimpleControlledVocabulary.where(predicate_name: name).order(:predicate_value).pluck(:predicate_value)
      end
    end
  end
end
