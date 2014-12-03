require 'hesburgh/lib/runner'

module Sip
  # A simple insulating layer between this application and Hesburgh::Lib
  #
  # Defines how the application layer interacts with the repository layer.
  #
  # The primary purpose of the Runner is to offload much of the processing
  # decisions from the controller. This instead lets the controller worry about
  # generating the correct response (e.g. render a template or redirect to
  # another URI) based on the results of the Runner.
  #
  # In offloading the processing from the controller, the runner can, with
  # minimal adjustments, operate in a different context. In other words, a
  # Runner could be used to build a suite of command-line commands.
  class BaseRunner < Hesburgh::Lib::Runner
    delegate :repository, to: :context
  end
end
