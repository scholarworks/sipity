module Sip
  # Responsible for capturing and validating the assignment of a DOI that
  # already exists but has not yet been assigned to the SIP
  class HeaderDoi < VirtualForm
    attr_reader :header
    attr_accessor :identifier
    def initialize(attributes = {})
      @decorator = attributes.fetch(:decorator) { default_decorator }
      self.header = attributes.fetch(:header)
      self.identifier = attributes.fetch(:identifier, nil)
      yield(self) if block_given?
    end

    validates :header, presence: true
    validates :identifier, presence: true

    def assign_a_doi_form
      self
    end

    def identifier_key
      AdditionalAttribute::DOI_PREDICATE_NAME
    end

    def request_a_doi_form
      HeaderDoiRequestForm.new(header: header, decorator: decorator)
    end

    def submit
      return false unless valid?
      return yield(self)
    end

    private

    def header=(header)
      @header = decorator.decorate(header)
    end

    attr_reader :decorator
    private :decorator

    def default_decorator
      HeaderDecorator
    end
  end
end
