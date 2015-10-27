class EtdExportRunner

  def self.call
    new.run
  end

  def initialize(work_area: default_work_area, requested_by: default_requested_by, form_builder: default_form_builder)
    self.work_area = work_area
    self.requested_by = requested_by
    self.form_builder = form_builder
  end

  def run
    target_entities do |work|
      form = form_builder.call(work: work, requested_by: requested_by)
      form.submit
    end
  end

  private

  attr_accessor :requested_by, :form_builder
  attr_reader :work_area

  def work_area=(input)
    @work_area = PowerConverter.convert_to_work_area(input)
  end

  def default_work_area
    'etd'
  end

  def default_requested_by
    Sipity::Models::Group.find_or_create_by!(name: Sipity::DataGenerators::WorkTypes::EtdGenerator::ETD_INGESTORS)
  end

  def default_form_builder
    Sipity::Forms::WorkSubmissions::Etd::SubmitForIngestForm.method(:new)
  end

  def target_entities
    # @TODO This is a tortured method. Lots of violations. Consider a concise and encapsulated query.
    Sipity::Models::WorkSubmission.where(work_area: work_area).include(
      work: { processing_entity: :strategy_state }
    ).find_each do |work_submission|
      work = work_submission.work
      yield(work) if work.processing_entity.strategy_state.name == 'ready_for_ingest'
    end
  end
end

EtdExportRunner.call
