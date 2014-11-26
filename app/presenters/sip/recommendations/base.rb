module Sip
  module Recommendations
    # The basis for any recommendation
    class Base
      extend ActiveModel::Translation

      attr_reader :header, :repository, :helper
      private :repository, :helper

      def initialize(header:, repository: nil, helper: nil)
        self.header = header
        @repository = repository || default_repository
        @helper = helper || default_helper
      end

      def path_to_recommendation
        fail NotImplementedError, "Expected #{self.class} to implement #path_to_recommendation"
      end

      def state
        fail NotImplementedError, "Expected #{self.class} to implement #state"
      end

      def human_status
        I18n.translate("state.#{state}", scope: translation_scope, title: header.title)
      end

      def human_name
        I18n.translate("name", scope: translation_scope, title: header.title)
      end

      def human_attribute_name(name)
        self.class.human_attribute_name(name)
      end

      private

      def header=(value)
        if value.respond_to?(:title)
          @header = value
        else
          fail NotImplementedError, "Expected #{value} to implement #title for #{self.class}#header"
        end
      end

      def default_repository
        Repository.new
      end

      def default_helper
        header.h
      end

      def translation_scope
        self.class.model_name.i18n_key
      end
    end
  end
end
