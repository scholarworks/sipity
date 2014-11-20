# As we ask our patrons to deposit things, one guiding question is whether
# or not they are planning to publish their deposit.
class DepositPublicationResponse
  # If we were not able to find the given key, provide some clue.
  class NotFoundError < RuntimeError
    def initialize(key)
      "Unable to find '#{key}' in #{KEYS.inspect}"
    end
  end

  KEYS = %w(will_not_publish already_published going_to_publish do_not_know).freeze

  TRANSLATION_BASE_SCOPE = 'models.publication_response'.freeze

  def self.each
    all.each { |response| yield(response) }
  end

  def self.all
    KEYS.map { |key| new(key) }
  end

  def self.include?(key)
    KEYS.include?(key.to_s)
  end

  def self.[](key)
    if include?(key)
      new(key)
    else
      fail NotFoundError, key
    end
  end

  class << self
    alias_method :find, :[]
    alias_method :fetch, :[]
  end

  def initialize(key)
    @key = key.to_s
  end
  attr_reader :key
  private :key

  def to_param
    key
  end

  def label
    I18n.t("label.#{key}", scope: TRANSLATION_BASE_SCOPE)
  end
  alias_method :to_s, :label

  def description
    I18n.t("description.#{key}", scope: TRANSLATION_BASE_SCOPE)
  end
end
