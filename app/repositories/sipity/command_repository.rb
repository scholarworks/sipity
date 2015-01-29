require_relative './commands'
module Sipity
  class CommandRepository < DelegateClass(QueryRepository)
    def initialize(query_repository_instance: QueryRepository.new)
      super(query_repository_instance)
    end

    include Commands

    def submit_etd_student_submission_trigger!
      fail NotImplementedError, "I want to expose this method, but I have layers of modules to consider"
    end

    def submit_ingest_etd
      fail NotImplementedError, "I want to expose this method, but I have layers of modules to consider"
    end
  end
end
