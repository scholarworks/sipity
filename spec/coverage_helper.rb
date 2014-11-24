if ENV['COV'] || ENV['COVERAGE'] || ENV['TRAVIS']
  if ENV['TRAVIS']
    require 'coveralls'
    require 'simplecov'
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
    Coveralls.wear!('rails')
  elsif ENV['COV'] || ENV['COVERAGE']
    require 'simplecov'
    SimpleCov.start do
      load_profile 'rails'
    end
  end
end
