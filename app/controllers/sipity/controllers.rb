module Sipity
  # Controllers are the HTTP end-points for the underlying router. In other
  # words, when an HTTP request comes in, the router will map the request to
  # a Controller's action. A controller represents a logical grouping of those
  # actions.
  #
  # @see Sipity::Runners::BaseRunner for reference to how individual actions
  #   can be written so as to detach the Action from the controller context, and
  #   thus make the underlying Action much more portable and reusable.
  #
  # @note Providing a namespace to group Sipity related controllers. Why go
  #   through this extra effort? Because without the Controllers namespace, the
  #   generated documentation -- via `$ yard` -- has a lot more objects in the
  #   same namespace.
  #
  # @note When you add controllers to this namespace, be mindful of the
  #   #controller_path method. Rails will use the module namespace to define
  #   where views can be found.
  module Controllers
    ROOT_VIEW_PATH = Rails.root.join('app/views/sipity/controllers').freeze

    module_function

    def build_processing_action_view_path_for(slug:)
      File.join(ROOT_VIEW_PATH, PowerConverter.convert_to_file_system_safe_file_name(slug))
    end
  end
end
