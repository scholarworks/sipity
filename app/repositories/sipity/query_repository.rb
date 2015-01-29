require_relative './queries'
module Sipity
  # Defines and exposes the query methods for interacting with the public API of
  # the persistence layer.
  class QueryRepository
    include Queries
  end
end
