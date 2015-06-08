module Sipity
  module Controllers
    module WorkAreas
      module Etd
        # Responsible for presenting an ETD work area
        #
        # TODO: Consider this presenter as a more complicated composition of
        #   both work area and submission window; That is more reflective of
        #   the reality.
        class ShowPresenter < WorkAreas::ShowPresenter
          def initialize(*args)
            super
            initialize_etd_variables!
          end

          def start_a_submission_path
            File.join(PowerConverter.convert(submission_window, to: :processing_action_root_path), start_a_submission_action.name)
          end

          def view_submitted_etds_url
            "https://curate.nd.edu"
          end

          private

          # TODO: There is a more elegant way to do this, but for now it is the
          # way things shall be done.
          ACTION_NAME_THAT_IS_HARD_CODED = 'start_a_submission'.freeze
          SUBMISSION_WINDOW_SLUG_THAT_IS_HARD_CODED = 'start'.freeze

          include Conversions::ConvertToProcessingAction
          def initialize_etd_variables!
            # Critical assumption about ETD structure. This is not a long-term
            # solution, but one to get things out the door.
            self.submission_window = repository.find_submission_window_by(
              slug: SUBMISSION_WINDOW_SLUG_THAT_IS_HARD_CODED, work_area: work_area
            )
            self.start_a_submission_action = convert_to_processing_action(ACTION_NAME_THAT_IS_HARD_CODED, scope: submission_window)
          end

          attr_accessor :submission_window, :start_a_submission_action
        end
      end
    end
  end
end
