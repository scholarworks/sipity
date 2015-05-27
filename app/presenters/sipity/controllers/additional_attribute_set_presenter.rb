module Sipity
  module Controllers
    # Responsible for presenting a set of additional attributes
    class AdditionalAttributeSetPresenter < Curly::Presenter
      presents :additional_attribute_set

      delegate :additional_attributes, to: :additional_attribute_set

      private

      attr_reader :additional_attribute_set
    end
  end
end
