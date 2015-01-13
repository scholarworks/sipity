module Sipity
  module Models
    # There are some answers that we ask our patrons to complete that are
    # prompts for additional thought or consideration. This model is the
    # persistence of those answers, and is to be used to continue prompting for
    # more permanent information.
    #
    # @example
    #   Question: What is the applicable Access Right?
    #   Possible Answers:
    #     * Open Access
    #     * Restricted
    #     * Private
    #     * It will change over time
    #
    #   In the case of Open Access, Restricted, and Private the answer is very
    #   simple; We make an entry in AccessRight that starts as of today for
    #   the given answer.
    #
    #   However, if the answer is "It will change over time", we don't want
    #   to present additional decision points immediately, but instead want
    #   to persist an answer that will require additional follow-up as we
    #   assist our patron in completing their SIP.
    #
    #   The follow-up to the answer would allow for us to introduce a complex
    #   decision in a more user focused and "gentle" manner. The idea being
    #   that the process of depositing something should be a conversation.
    class TransientAnswer < ActiveRecord::Base
      self.table_name = 'sipity_transient_answers'

      ACCESS_RIGHTS_QUESTION = 'access_rights'.freeze
      ACCESS_RIGHTS_PRIVATE = 'private_access'.freeze

      QUESTIONS = [ACCESS_RIGHTS_QUESTION].freeze

      ANSWERS = {
        ACCESS_RIGHTS_QUESTION => [
          'open_access', 'restricted_access', ACCESS_RIGHTS_PRIVATE, 'access_changes_over_time'
        ].freeze
      }.freeze

      # TODO: Should there be validation concerning the question and answer?

      belongs_to :entity, polymorphic: true
    end
  end
end
