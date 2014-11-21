module Sip
  # A decoration layer for Sip::Collaborator
  class CollaboratorDecorator < Draper::Decorator
    delegate_all

    def possible_roles
      object.class.roles
    end

    def human_attribute_name(name)
      object.class.human_attribute_name(name)
    end
  end
end
