require_relative './repository_methods'
module Sipity
  # Defines and exposes the methods for interacting with the public API of the
  # persistence layer.
  #
  # @note Yes I am using module mixins. Yes there are lots of methods in this
  #   class. Each of the mixins are tested in isolation. It is possible that
  #   there could be method collisions, but see the underlying specs for
  #   additional discussion and verification of method collisions.
  #
  # @note Why is the Sipity::Services module and Sipity::Repository at the
  #   same module level? Right now, I believe that is a mistake. It makes sense
  #   to me that there will be multiple repository objects; After all some
  #   objects are going to come from another persistence service (i.e. DB or
  #   Fedora commons). I suspect there will be a negotiation layer to determine
  #   which persistence service to retrieve an entity from. That is to say if
  #   you want to edit an object ingested into Fedora you might request the
  #   object from Fedora, then request the object from a DB and layer the DB
  #   values on top of the Fedora values.
  class Repository
    # TODO: Separate Command and Query methods; This way other classes can
    #   make use query methods without exposing command methods.
    include RepositoryMethods

    def submit_etd_student_submission_trigger!
      fail NotImplementedError, "I want to expose this method, but I have layers of modules to consider"
    end

    def assign_group_roles_to_entity
      fail NotImplementedError, "I want to expose this method, but I have layers of modules to consider"
    end

    def send_notification_for_entity_trigger(*_)
      fail NotImplementedError, "I want to expose this method, but I have layers of modules to consider"
    end

    def submit_ingest_etd
      fail NotImplementedError, "I want to expose this method, but I have layers of modules to consider"
    end
  end
end
