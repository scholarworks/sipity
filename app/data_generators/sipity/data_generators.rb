module Sipity
  # Sipity levereages a lot of data-driven configuration. This module is a place
  # to provide classes and infrastructure for bootstrapping the configuration
  # related data entries.
  #
  # Instead of having these objects sit amongst the "services bucket", I want to
  # sequester them into their own space.
  #
  # Objects in the DataGenerators module are present for "bootstrapping"
  # via a developer/sys admin's command line; They represent the necessary
  # steps to bootstrap a viable ecosystem.

  # Yet they are not seeds; They encompass the logic required to get
  # certain "foundational" elements up and running. They also represent
  # a crease in the code that will allow us to craft plugins for new
  # Work Areas, Submission Windows, and Work Types.
  #
  # ## Why Not Factories?
  #
  # Because of the ubiquitous FactoryGirl, I am avoiding the name of Factory.
  # In using the term DataScaffolds I hope to convey that these more closely
  # resemble a rails generator; In other words, use the data generators to
  # help bootstrap the application.
  module DataGenerators
  end
end
