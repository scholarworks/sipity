module Sip
  # These are the service methods container. As I work on building the
  # more complicated data entry, I believe this will be required.
  class Repository
    def find_header(header_id)
      Header.find(header_id)
    end
  end
end
