require 'power_converter'
Dir.glob(Rails.root.join("app/conversions/power_converters/**/*.rb")).each { |filename| require filename }
