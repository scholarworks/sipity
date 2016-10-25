require 'power_converters/access_path'
PowerConverter.define_conversion_for(:processing_action_root_path) do |input|
  File.join(PowerConverter.convert(input, to: :access_path), 'do')
end
