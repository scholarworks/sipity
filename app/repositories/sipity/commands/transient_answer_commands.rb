module Sipity
  # :nodoc:
  module Commands
    # Responsible for applying various transient answers to an entity. In some
    # cases additional commands may fire.
    #
    # @see Sipity::Models::TransientAnswer
    module TransientAnswerCommands
      def handle_transient_access_rights_answer(entity:, answer:)
        Models::AccessRight.create!(entity: entity, access_right_code: answer)
      end
    end
  end
end
