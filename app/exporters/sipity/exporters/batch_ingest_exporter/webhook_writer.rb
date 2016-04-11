module Sipity
  module Exporters
    class BatchIngestExporter
      # Adds a list of URLs to the WEBHOOK file that are called during the batch
      # ingest process.
      module WebhookWriter
        module_function

        def call(exporter:)
          exporter.make_data_directory
          write_contents(
            target: output_buffer(filename: target_path(exporter: exporter)),
            content: callback_url(exporter: exporter)
          )
        end

        def write_contents(target:, content:)
          target.write(content)
          target.close_write
        end

        def output_buffer(filename:)
          file_descriptor = IO.sysopen(filename, 'w+')
          IO.new(file_descriptor)
        end

        def target_path(exporter:)
          File.join(exporter.data_directory, 'WEBHOOK')
        end

        def callback_url(exporter:)
          File.join(
            "#{Figaro.env.protocol!}://#{authorization_credentials}@#{Figaro.env.domain_name!}",
            "/work_submissions/#{exporter.work_id}/callback/ingest_completed.json"
          )
        end

        def authorization_credentials
          "#{Sipity::Models::Group::BATCH_INGESTORS}:#{Figaro.env.sipity_batch_ingester_access_key!}"
        end
      end
    end
  end
end
