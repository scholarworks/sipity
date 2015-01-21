require 'rack/test'

module FileUpload
  module_function

  def fixture_file_upload(path, *args)
    pathname = pathname_for(path)
    Rack::Test::UploadedFile.new(pathname.to_s, *args)
  end

  def pathname_for(path)
    Pathname.new(File.join(File.expand_path('../../fixtures', __FILE__), path))
  end
end
