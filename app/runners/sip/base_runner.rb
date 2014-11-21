require 'hesburgh/lib/runner'

module Sip
  # A simple insulating layer between this application and Hesburgh::Lib
  class BaseRunner < Hesburgh::Lib::Runner
    delegate :repository, to: :context
  end
end
