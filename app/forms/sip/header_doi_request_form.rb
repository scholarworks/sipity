module Sip
  # Submit a request for a DOI for the given Header
  class HeaderDoiRequestForm
    include ActiveModel::Validations
    extend ActiveModel::Translation

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

    def to_key
      []
    end

    def to_param
      nil
    end

    def persisted?
      false
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
