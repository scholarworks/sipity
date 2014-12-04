module Sip
  # Submit a request for a DOI for the given Header
  class RequestADoiForm < VirtualForm
    def initialize(attributes = {})
      self.header = attributes.fetch(:header)
      @publisher, @publication_date = attributes.values_at(:publisher, :publication_date)
      yield(self) if block_given?
    end

    attr_accessor :publisher, :publication_date, :header
    private :header=

    delegate :title, to: :header

    validates :header, presence: true
    validates :publisher, presence: true
    validates :publication_date, presence: true

    def authors
      header.authors
    end
  end
end
