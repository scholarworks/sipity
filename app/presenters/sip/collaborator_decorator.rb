module Sip
  # A decoration layer for Sip::Collaborator
  class CollaboratorDecorator < Draper::Decorator
    delegate_all

    def possible_roles
      object.class.roles
    end
  end
end
