module Sipity
  module Controllers
    module WorkAreas
      # Responsible for showing a work area
      class ShowPresenter < Curly::Presenter
        presents :view_object

        def resourceful_actions
          @resourceful_actions ||= processing_actions.resourceful_actions
        end

        def resourceful_actions?
          resourceful_actions.present?
        end

        private

        def processing_actions
          @processing_actions ||= Decorators::ProcessingActions.new(user: current_user, entity: view_object)
        end
      end
    end
  end
end
