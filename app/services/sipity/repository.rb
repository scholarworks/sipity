module Sipity
  # Defines and exposes the methods for interacting with the public API of the
  # persistence layer.
  class Repository
    include Sipity::Repo::HeaderMethods
    include Sipity::Repo::CitationMethods
    include Sipity::Repo::DoiMethods

    def policy_authorized_for?(user:, policy_question:, entity:)
      Policies.policy_authorized_for?(user: user, policy_question: policy_question, entity: entity)
    end
  end
end
