module Sipity
  # ResponseHandlers are a means of encapsulating how we respond to an action's
  # response. Action responses should implement the interface of the
  # HandledResponseParameter.
  #
  # This is experimental; After conversations with @terrellt I wanted to
  # eliminate the callbacks of the runners. They were helpful to convey what was
  # happening. I believe the callbacks have reduced some of the complexities
  # of controller testing. There was room for more, and I hope that is made
  # clear through this experimentation.
  #
  # @see Sipity::Parameters::HandledResponseParameter
  # @see Sipity::Runners::BaseRunner
  module ResponseHandlers
  end
end
