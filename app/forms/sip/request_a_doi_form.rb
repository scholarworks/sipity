module Sip
  # Submit a request for a DOI for the given Header
  class RequestADoiForm < VirtualForm
    attr_reader :header
    attr_accessor :publisher, :publication_date
    delegate :title, to: :header

    def initialize(attributes = {})
      @decorator = attributes.fetch(:decorator) { default_decorator }
      self.header = attributes.fetch(:header)
      @publisher, @publication_date = attributes.values_at(:publisher, :publication_date)
      yield(self) if block_given?
    end

    validates :publisher, presence: true
    validates :publication_date, presence: true

    def authors
      header.authors
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
