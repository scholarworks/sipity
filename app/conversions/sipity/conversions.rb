module Sipity
  # Taking a que from Avdi Grimm's "Confident Ruby", the Conversion module
  # is responsible for coercing the inputs to another format.
  #
  # This is somewhat experimental, though analogous to the Array() method in
  # base ruby.
  #
  # This module is defined here to provide the top-level declaration.
  #
  # Any Conversion modules should be callable and includable. By calling the
  # module you would perform the singular conversion. By including the module
  # you would gain access to the private conversion method.
  #
  # @see Sipity::Conversions::ConvertToYear
  module Conversions
  end
end
