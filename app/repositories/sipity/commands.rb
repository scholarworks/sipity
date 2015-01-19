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
    extend ActiveSupport::Concern

    included do |base|
      base.send(:include, WorkCommands)
      base.send(:include, DoiCommands)
      base.send(:include, EventLogCommands)
      base.send(:include, AccountPlaceholderCommands)
      base.send(:include, NotificationCommands)
      base.send(:include, AdditionalAttributeCommands)
      base.send(:include, PermissionCommands)
      base.send(:include, TransientAnswerCommands)
    end
  end
end

Dir[File.expand_path('../commands/*.rb', __FILE__)].each do |filename|
  require_relative "./commands/#{File.basename(filename)}"
end
