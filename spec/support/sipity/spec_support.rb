module Sipity
  module SpecSupport
    module_function

    def load_database_seeds!(seeds_path: 'db/seeds.rb')
      toggle_stdout do
        load Rails.root.join(seeds_path).to_s
      end
    end

    def toggle_stdout
      # Catching the output for loading the database seeds
      old_stdout = $stdout
      $stdout = StringIO.new
      yield
    ensure
      $stdout = old_stdout
    end
  end
end
