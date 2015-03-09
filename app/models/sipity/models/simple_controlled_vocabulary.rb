module Sipity
  module Models
    # Responsible for defining what values are allowed for a given predicate.
    #
    # @todo - Convert Sipity::ModelCollaborators#role to use controlled
    #   vocabulary based on work type. That will be important once we have
    #   collaborator's roles vary by work type (i.e. does a Doctoral
    #   Dissertation have different roles from a Master's Thesis, or from a
    #   Conference Presentation).
    #
    # @note - At present the controlled vocabularies do not vary based on
    #   any work type; However that is one potentiaul future variance.
    class SimpleControlledVocabulary < ActiveRecord::Base
      self.table_name = 'sipity_simple_controlled_vocabularies'

      enum(
        predicate_name: {
          AdditionalAttribute::DEGREE_PREDICATE_NAME => AdditionalAttribute::DEGREE_PREDICATE_NAME,
          AdditionalAttribute::PROGRAM_NAME_PREDICATE_NAME => AdditionalAttribute::PROGRAM_NAME_PREDICATE_NAME
        }
      )
    end
  end
end
