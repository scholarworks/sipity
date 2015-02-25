module Sipity
  # Taking a que from Avdi Grimm's "Confident Ruby", the Conversion module
  # is responsible for coercing the inputs to another format.
  #
  # ## Why Conversions?
  #
  # Sipity is comprised of several sub-systems. The Processing subsystem is
  # something that I envision extracting at a future date. However, the forms
  # and data capture servcies need to interact with those subsystems in a
  # predictable way.
  #
  # So, in order to ease moving across various boundaries, I'm opting to use
  # conversion modules. These modules expose the means of transforming (or
  # denying the transformation) an object into another type. In other words they
  # document how one object can map to another object.
  #
  # ## About Conversion Module Implementation
  #
  # Any Conversion module should be call-able and include-able. These two
  # patterns are provided as a matter of convenience.
  #
  # The call-able pattern exposes a public method `.call` that peforms the
  # corresponding conversion.
  #
  # The include-able pattern will add a private method that can be used to
  # perform the conversion. In this pattern, the call method will not be added
  # as a method on the including class.
  #
  # In both the Callable and Includable pattern, the conversion method will not
  # be publicly visible. That means if you attempt to call the module function,
  # it will indicate that it is private.
  #
  # @note This module is defined here to provide the top-level documentation and
  #   declaration.
  #
  # @see Sipity::Conversions::ConvertToYear and correspoding specs
  # @see http://confidentruby.com Avdi Grimm's "Confident Ruby"
  module Conversions
  end
end
