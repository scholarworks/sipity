module Sipity
  module Decorators
    module Recommendations
      # The basis for any recommendation
      class Base
        extend ActiveModel::Translation

        attr_reader :work, :repository, :helper
        private :repository, :helper

        def initialize(work:, repository: nil, helper: nil)
          self.work = work
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
          I18n.translate("state.#{state}", scope: translation_scope, title: work.title)
        end

        def human_name
          I18n.translate("name", scope: translation_scope, title: work.title)
        end

        def human_attribute_name(name)
          self.class.human_attribute_name(name)
        end

        private

        def work=(value)
          if value.respond_to?(:title)
            @work = value
          else
            fail NotImplementedError, "Expected #{value} to implement #title for #{self.class}#work"
          end
        end

        def default_repository
          Repository.new
        end

        def default_helper
          work.h
        end

        def translation_scope
          self.class.model_name.i18n_key
        end
      end
    end
  end
end
