module Sip
  # Responsible for capturing and validating the assignment of a DOI that
  # already exists but has not yet been assigned to the SIP
  class AssignADoiForm < VirtualForm
    def initialize(attributes = {})
      @decorator = attributes.fetch(:decorator) { default_decorator }
      self.header = attributes.fetch(:header)
      self.identifier = attributes.fetch(:identifier, nil)
      yield(self) if block_given?
    end

    attr_reader :header
    attr_accessor :identifier
    validates :header, presence: true
    validates :identifier, presence: true

    def assign_a_doi_form
      self
    end

    def identifier_key
      AdditionalAttribute::DOI_PREDICATE_NAME
    end

    def request_a_doi_form
      RequestADoiForm.new(header: header, decorator: decorator)
    end

    private

    def header=(header)
      @header = decorate(object: header, decorator: decorator)
    end

    attr_reader :decorator
    private :decorator

    def default_decorator
      HeaderDecorator
    end
  end
end
