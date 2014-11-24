module Sip
  # Submit a request for a DOI for the given Header
  class HeaderDoiRequestForm < VirtualForm
    attr_reader :header
    attr_accessor :publisher, :publication_date
    delegate :title, to: :header

    def initialize(attributes = {})
      @decorator = attributes.fetch(:decorator) { default_decorator }
      self.header = attributes.fetch(:header)
      @publisher, @publication_date = attributes.values_at(:publisher, :publication_date)
      yield(self) if block_given?
    end

    def authors
      header.authors
    end

    private

    def header=(header)
      if header.respond_to?(:decorate)
        @header = header
      else
        @header = decorator.decorate(header)
      end
    end

    attr_reader :decorator
    private :decorator

    def default_decorator
      HeaderDecorator
    end
  end
end
