require 'power_converters/access_path'
PowerConverter.define_conversion_for(:processing_action_root_path) do |input|
  File.join(PowerConverter.convert_to_access_path(input), 'do')
end
