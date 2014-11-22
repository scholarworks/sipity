if ENV['COV'] || ENV['COVERAGE'] || ENV['TRAVIS']
  if ENV['COV'] || ENV['COVERAGE']
    require 'simplecov'
    SimpleCov.start do
      load_profile 'rails'
    end
  elsif ENV['TRAVIS']
    require 'coveralls'
    require 'simplecov'
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
    Coveralls.wear!('rails')
  end
end
