module Sipity
  # :nodoc:
  module RepositoryMethods
    # Responsible for coordinating with the notification layer.
    # What is the notification layer? Don't know yet. But I suspect it will
    # be us sending various emails to recipients.
    module NotificationMethods
      extend ActiveSupport::Concern
      included do |base|
        base.send(:include, Commands::NotificationCommands)
      end
    end
  end
end
