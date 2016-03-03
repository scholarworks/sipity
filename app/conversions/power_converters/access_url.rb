require 'power_converters/access_path'
PowerConverter.define_conversion_for(:access_url) do |input|
  case input
  when Sipity::Models::Attachment
    input.file_url
  else
    File.join(Figaro.env.url_host, PowerConverter.convert_to_access_path(input))
  end
end
