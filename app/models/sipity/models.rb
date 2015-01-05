module Sipity
  # Models are the persisted objects. They are the closest representation of
  # the persistence layer tables/documents.
  #
  # @note Do **NOT** put behavior in the Models. Treat the models as data
  #   structures.
  module Models
    # Because I want greater control of the names. Changes the polymorphic
    # pathing to something a bit less chatty (i.e. from sipity_models_sip_path
    # to sip_path).
    #
    # @see https://github.com/rails/rails/blob/8742bc9d5e030b4ac6119d61a163ba72c2e7e380/activemodel/lib/active_model/naming.rb#L222-L241
    def self.use_relative_model_naming?
      true
    end
  end
end
