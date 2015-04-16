module Sipity
  # A module for putting objects that are passed across boundaries.
  #
  # Instead of using mocks, you can use an object in Sipity::Parameters.
  #
  # @see https://sourcemaking.com/refactoring/introduce-parameter-object
  #
  # @note Experimental: I had thought about calling this module space "Values"
  #   but felt that parameters is more specific. Parameter also implies
  #   something "in motion", and as I don't know if this module will endure for
  #   the long haul, I want imply that it is "in mothion".
  #
  # @todo Consider making an interface for a Parameter object.
  module Parameters
  end
end
