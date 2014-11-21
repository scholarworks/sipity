module Sip
  # Responsible for capturing and validating the assignment of a DOI that
  # already exists but has not yet been assigned to the SIP
  class HeaderDoi
    include ActiveModel::Validations
    extend ActiveModel::Translation

    attr_reader :identifier, :header
    def initialize(attributes = {})
      @header, @identifier = attributes.values_at(:header, :identifier)
      yield(self) if block_given?
    end

    validates :header, presence: true
    validates :identifier, presence: true

    def to_key
      []
    end

    def to_param
      nil
    end

    def persisted?
      false
    end
  end
end
