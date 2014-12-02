module Sip
  # Responsible for exposing attributes for editing
  #
  # TODO: Expose setter and getter methods for each exposed_attribute_name
  class EditHeaderForm
    def initialize(header:, exposed_attribute_names: [], attributes: {})
      @header = header
      @attributes = attributes
      @exposed_attribute_names = exposed_attribute_names
    end
  end
end
