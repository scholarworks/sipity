module Sip
  # Responsible for capturing and validating information for citation creation.
  class AssignACitationForm < VirtualForm
    def initialize(attributes = {})
      @header = attributes.fetch(:header)
      @type, @citation = attributes.values_at(:type, :citation)
    end
    attr_accessor :type, :citation
    attr_reader :header

    validates :citation, presence: true
    validates :type, presence: true
  end
end
