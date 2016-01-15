path = Rails.root.join('app/data_generators/sipity/data_generators/work_areas/ulra_work_area.config.json')
Sipity::DataGenerators::WorkAreaGenerator.call(path: path)
