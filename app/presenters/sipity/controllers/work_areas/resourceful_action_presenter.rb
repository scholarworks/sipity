module Sipity
  module Controllers
    module WorkAreas
      # Responsible for rendering a resourceful action in the context of a
      # WorkArea.
      class ResourcefulActionPresenter < Sipity::Controllers::ResourcefulActionPresenter
        presents :work_area

        attr_reader :work_area
        private :work_area

        delegate :slug, to: :work_area, prefix: :work_area

        def to_work_area
          work_area
        end

        def path
          work_area_action_path(work_area_slug: work_area_slug, processing_action_name: action_name)
        end
      end
    end
  end
end
