module Sip
  # Models are the persisted objects. They are the closest representation of
  # the persistence layer tables/documents.
  module Models
    # Because I want greater control of the names. Changes the polymorphic
    # pathing to something a bit less chatty (i.e. from sip_models_header_path
    # to header_path).
    #
    # @see https://github.com/rails/rails/blob/8742bc9d5e030b4ac6119d61a163ba72c2e7e380/activemodel/lib/active_model/naming.rb#L222-L241
    def self.use_relative_model_naming?
      true
    end
  end
end
