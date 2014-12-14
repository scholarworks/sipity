module Sipity
  # Defines and exposes the methods for interacting with the public API of the
  # persistence layer.
  #
  # @note Yes I am using module mixins. Yes there are lots of methods in this
  #   class. Each of the mixins are tested in isolation. It is possible that
  #   there could be method collisions, but see the underlying specs for
  #   additional discussion and verification of method collisions.
  class Repository
    include Sipity::Repo::HeaderMethods
    include Sipity::Repo::CitationMethods
    include Sipity::Repo::DoiMethods
  end
end
