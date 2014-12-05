module Sip
  # Contains the various Forms associated with Sipity.
  #
  # Forms are a class of objects that are different from models. They may
  # represent a subset of a single model's attributes, or be a composition of
  # multiple objects.
  #
  # A form's purpose is to:
  #
  #   * Expose attributes
  #   * Validate attributes
  #
  # They are things that could be rendered via the `simple_form_for` view
  # template method.
  #
  # @note By introducing Forms, there is less of a reliance on the anti-pattern
  #   of Strong Patterns. That is to say, only expose explicit attributes to the
  #   UI. And should the controller be the thing saying what parameters are
  #   permitted for mass assignment? Not if you intend to create command line
  #   tools.
  # @see [Nick Sutterer's Reform gem](http://github.com/apotonick/reform) for
  #   additional commentary and reason for separating forms from their
  #   underlying ActiveRecord classes.
  module Forms
  end
end
