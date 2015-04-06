module Sipity
  module Services
    # Responsible for determining if a given string is a valid NetID
    module RemoteNetidValidator
      module_function

      # @param [String] possible_netid
      # @return [false] if the input is not a valid NetID
      # @return [String] if the input is a valid NetID
      def valid_netid?(possible_netid)
        Services::NetidQueryService.valid_netid?(netid: possible_netid)
      end
    end
  end
end
