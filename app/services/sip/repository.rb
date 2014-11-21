module Sip
  class Repository
    def find_header(header_id)
      Header.find(header_id)
    end
  end
end
