module Sipity
  # Responsible for processing a single concept in an asynchronous manner.
  # That means we are only passing primatives to the Jobs and it is
  # the Jobs responsibility to reify the correct objects.
  #
  # @see https://github.com/resque/resque Resque gem
  module Jobs
    # Herein lies the inflection point. If you want to run things
    # asynchronously, this is your place to make changes.
    def submit(job_name, *args)
      job = find_job_by_name(job_name)
      verify_primativeness_of!(*args)
      job.call(*args)
    end
    module_function :submit

    def find_job_by_name(job_name)
      job_name_as_constant = "#{job_name.to_s.underscore}_job".classify
      return "#{self}::#{job_name_as_constant}".constantize
    rescue NameError
      raise Exceptions::JobNotFoundError, name: job_name_as_constant, container: self
    end
    module_function :find_job_by_name

    def verify_primativeness_of!(*)
      # REVIEW: Would it make sense to verify that each of the args is a
      #   primative? Given that we could be passing this information through
      #   REDIS
      true
    end
    module_function :verify_primativeness_of!
    private_class_method :verify_primativeness_of!
  end
end
