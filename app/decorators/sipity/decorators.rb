module Sipity
  # Contains the various Decorators associated with Sipity. The primary
  # responsibility of a decorator is to encapsulate view related logic that is
  # associated with a model. Things like URLs, translations, etc.
  #
  # @note Take a look at the [Draper gem](https://github.com/drapergem/draper).
  #   It does a great job of explaining their importance.
  # @note Establishing module name
  module Decorators
    module_function

    # A function to help you build a ComparableDecoratorClass
    #
    # @example
    #   class DecoratorBook < Decorators::ComparableDelegateClass(Book)
    #     # Further details of your class
    #   end
    #
    # @todo Extract this to the hesburgh-lib
    def ComparableDelegateClass(base_class)
      # TODO: Do not duplicate the class for a given base_class?
      klass = Class.new(ComparableSimpleDelegator)
      klass.base_class = base_class
      klass
    end
  end
end
