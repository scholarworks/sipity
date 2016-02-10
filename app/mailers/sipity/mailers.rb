require 'sipity/exceptions'

module Sipity
  # Sipity::Mailers are responsible for sending out emails. This module
  # provides the interface for finding the correct mailer for a given context.
  module Mailers
    # @api public
    #
    # Responsible for finding the correct mailer for the given entity and notification
    #
    # @param entity [#to_work_area]
    # @param notification [String,Symbol]
    #
    # @return subclass of ActionMailer::Base
    def self.find_mailer_for(entity:, notification:)
      mailer = mailer_for(entity: entity)
      return mailer if mailer.respond_to?(notification)
      raise Exceptions::NotificationNotFoundError, name: notification, container: mailer
    end

    def self.mailer_for(entity:)
      work_area = PowerConverter.convert(entity, to: :work_area)
      mailer_name_as_constant = "#{work_area.demodulized_class_prefix_name}Mailer"
      return "#{self}::#{mailer_name_as_constant}".constantize
    end
    private_class_method :mailer_for
  end
end
