module Sipity
  module Exporters
    # Responsible for coordinating sending a work through the batch ingest.
    class BatchIngestExporter
      # The batch ingest process is triggered by file operations. When the data
      # preparation is complete its containing directory is moved to the "queue"
      # directory. This module manages moving the data.
      module DirectoryMover
        DEFAULT_DESTINATION = Figaro.env.curate_batch_queue_mount_path!

        module_function

        def call(exporter:, destination_path: DEFAULT_DESTINATION)
          prepare_destination(path: destination_path)
          move_files(source: exporter.data_directory, destination: destination_path)
        end

        def prepare_destination(path:)
          FileUtils.mkdir_p(path)
        end

        def move_files(source:, destination:)
          FileUtils.mv(source, File.join(destination, '/'))
        end
      end
    end
  end
end
