module Sipity
  module Mailers
    class EmailNotifier < ActionMailer::Base
      default from: 'curate@nd.edu', return_path: 'no-reply@nd.edu'
      layout 'mailer'
    end
  end
end
