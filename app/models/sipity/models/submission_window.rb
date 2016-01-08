module Sipity
  module Models
    # A conceptual container of when things can be added to the given WorkArea
    class SubmissionWindow < ActiveRecord::Base
      self.table_name = 'sipity_submission_windows'

      belongs_to :work_area
      delegate :slug, :partial_suffix, to: :work_area, prefix: :work_area

      has_many :submission_window_work_types, dependent: :destroy
      has_many :work_submissions, dependent: :destroy

      Processing.configure_as_a_processible_entity(self)

      has_one :strategy_usage, as: :usage, class_name: 'Sipity::Models::Processing::StrategyUsage', dependent: :destroy

      def slug=(value)
        super(PowerConverter.convert(value, to: :slug))
      end

      def to_s
        slug
      end
    end
  end
end
