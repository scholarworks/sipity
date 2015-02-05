module Sipity
  # The module that contains various interactions with the underlying
  # persistence layer.
  module Commands
  end

  # The object you can use to interaction with the commands.
  class CommandRepository < DelegateClass(QueryRepository)
    def initialize(query_repository_instance: QueryRepository.new)
      super(query_repository_instance)
    end

    include Commands::WorkCommands
    include Commands::DoiCommands
    include Commands::EventLogCommands
    include Commands::NotificationCommands
    include Commands::AdditionalAttributeCommands
    include Commands::PermissionCommands
    include Commands::TransientAnswerCommands
    include Commands::TodoListCommands

    def submit_etd_student_submission_trigger!
      fail NotImplementedError, "I want to expose this method, but I have layers of modules to consider"
    end

    def submit_ingest_etd
      fail NotImplementedError, "I want to expose this method, but I have layers of modules to consider"
    end
  end
end
