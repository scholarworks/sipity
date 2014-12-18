module Sipity
  # These are the "read" methods for services. They are responsible for
  # retrieving information.
  #
  # In separating them, I hope to expose a Respository::ReadOnly. A longer term
  # goal is to craft custom repository collaborators based on the context.
  #
  # In keeping the queries separate and the concerns small, it would be feasible
  # to enrich domain objects with methods from the Queries namespace.
  #
  # @see http://martinfowler.com/bliki/CommandQuerySeparation.html Martin
  #   Folwer's article on Command/Query separation
  module Queries
  end
end
