# Slugs should be human and machine readable
#
# > We recommend that you use hyphens (-) instead of underscores (_) in your
# > URLs.
#
# https://support.google.com/webmasters/answer/76329?hl=en
PowerConverter.define_conversion_for(:slug) do |input|
  case input
  when Symbol, String, NilClass
    input.to_s.gsub(/\W+/, '_').underscore.gsub(/_+/, '-').downcase
  end
end
