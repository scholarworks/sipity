module Sipity
  # These are the "write" methods for services. They are responsible for
  # updating state.
  #
  # In separating them, I hope to expose a Respository::ReadWrite. A longer term
  # goal is to craft custom repository collaborators based on the context.
  #
  #
  # @see http://martinfowler.com/bliki/CommandQuerySeparation.html Martin
  #   Folwer's article on Command/Query separation
  module Commands
  end
end
