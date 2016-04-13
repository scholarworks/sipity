Dir.glob(File.expand_path('../**/*_queries.rb', __FILE__)).each do |filename|
  require filename
end

module Sipity
  # The module that contains the various query submodules
  module Queries
  end
  # Defines and exposes the query methods for interacting with the public API of
  # the persistence layer.
  #
  # @note In developing repository methods, do not set nor get instance variables for a repository instance.
  # @note These methods should be stateless.
  class QueryRepository
    Queries.constants.each do |query_module|
      include Queries.const_get(query_module)
    end
  end
end
