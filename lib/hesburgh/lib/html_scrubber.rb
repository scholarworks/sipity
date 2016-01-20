require 'loofah/scrubber'

module Hesburgh
  module Lib
    # Exposes a consistent means of scrubbing HTML.
    #
    # @see Rails `sanitize` method
    # @todo Extract to the Hesburgh::Lib gem
    module HtmlScrubber
      ALLOWED_INLINE_TAGS = %w(abbr acronym b big cit cite code dfn em i mark samp small strong sub sup time tt var).freeze
      ALLOWED_INLINE_WITH_LINK_TAGS = (%w(a) + ALLOWED_INLINE_TAGS).freeze
      ALLOWED_INLINE_ATTRIBUTES = %w(datetime title href rel dir).freeze
      ALLOWED_BLOCK_ATTRIBUTES = ALLOWED_INLINE_ATTRIBUTES

      # We want to render this information as part of the metadata of a page. Examples include the `html head title` attribute
      def self.build_meta_tag_scrubber(tags: [], attributes: :fallback)
        AllowedTagsScrubber.new(tags: tags, attributes: attributes)
      end

      # We expect a single line of content. Examples include a "title" of an item
      def self.build_inline_scrubber(tags: ALLOWED_INLINE_TAGS, attributes: ALLOWED_INLINE_ATTRIBUTES)
        AllowedTagsScrubber.new(tags: tags, attributes: attributes)
      end

      # We expect a single line of content but are allowing links (A-tags) to be included.
      def self.build_inline_with_link_scrubber(tags: ALLOWED_INLINE_WITH_LINK_TAGS, attributes: ALLOWED_INLINE_ATTRIBUTES)
        AllowedTagsScrubber.new(tags: tags, attributes: attributes)
      end

      # We are allowing multiple lines of content. Examples include an "abstract" of an item
      def self.build_block_scrubber
        AllowedTagsScrubber.new(tags: AllowedTagsScrubber::FALLBACK, attributes: ALLOWED_BLOCK_ATTRIBUTES)
      end

      # Responsible for stripping and general sanitization of HTML documents
      class AllowedTagsScrubber < Loofah::Scrubber
        FALLBACK = :fallback
        # @param tags [Symbol, Array<String>] What are the tags we are we going to keep. Otherwise the tag (but not content) is stripped.
        # @param attributes [Symbol, Array<String>] What are the attributes we are we going to keep? Otherwise the attribute and its value
        #                                           are dropped.
        # @param direction [Symbol] How are we processing the nodes; This is an assumption based on the Loofah::Scrubber
        def initialize(tags: FALLBACK, attributes: FALLBACK, direction: :bottom_up)
          self.direction = direction
          self.tags = tags
          self.attributes = attributes
        end

        # A convenience method for sanitiziation
        def sanitize(input)
          return '' unless input.present?
          return input unless input.is_a?(String)
          Loofah.fragment(input).scrub!(self).to_s.strip
        end
        alias call sanitize

        def scrub(node)
          return node.remove if script_node?(node)
          if node_allowed?(node)
            scrub_node_attributes(node)
            return CONTINUE
          else
            node.before node.children
            node.remove
          end
        end

        private

        attr_reader :tags, :attributes
        attr_accessor :direction

        def tags=(input)
          @tags = extract_with_fallback_consideration(input)
        end

        def attributes=(input)
          @attributes = extract_with_fallback_consideration(input)
        end

        def extract_with_fallback_consideration(input)
          return FALLBACK if input == FALLBACK
          Array.wrap(input)
        end

        def script_node?(node)
          node.name == 'script'
        end

        def scrub_node_attributes(node)
          return fallback_scrub_node_attributes(node) if attributes == FALLBACK
          node.attribute_nodes.each do |attr_node|
            attr_node.remove unless attributes.include?(attr_node.name)
          end
        end

        def allowed_not_element_node_types
          [Nokogiri::XML::Node::TEXT_NODE, Nokogiri::XML::Node::CDATA_SECTION_NODE]
        end

        def fallback_scrub_node_attributes(node)
          Loofah::HTML5::Scrub.scrub_attributes(node)
          true
        end

        def fallback_allowed_element_detection(node)
          Loofah::HTML5::Scrub.allowed_element?(node.name)
        end

        def node_allowed?(node)
          return fallback_allowed_element_detection(node) if tags == FALLBACK
          return true if allowed_not_element_node_types.include?(node.type)
          return false unless node.type == Nokogiri::XML::Node::ELEMENT_NODE
          tags.include?(node.name)
        end
      end
      private_constant :AllowedTagsScrubber
    end
  end
end
