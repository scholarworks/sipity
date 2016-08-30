require 'active_support/core_ext/array/wrap'
require 'simple_form/inputs/collection_input'

require 'simple_form'
# Customization for multi-valued input field
class MultiValueInput < SimpleForm::Inputs::CollectionInput
  def input(*)
    @rendered_first_element = false
    input_html_classes.unshift("string")
    input_html_options[:multiple] = multiple?
    input_html_options[:type] ||= 'text'
    input_html_options[:name] ||= "#{object_name}[#{attribute_name}][]"
    markup = <<-HTML
      <ul class="listing">
    HTML
    list_builder(markup)
  end

  def input_type
    'multi-value'
  end

  private

  def list_builder(markup)
    collection.each do |value|
      next if value.to_s.strip.blank?
      markup << <<-HTML
        <li class="field-wrapper">
          #{build_text_field(value)}
        </li>
      HTML
    end
    empty_line_builder(markup)
  end

  def empty_line_builder(markup)
    markup << <<-HTML
          <li class="field-wrapper">
            #{build_text_field('')}
          </li>
        </ul>
    HTML
  end

  def build_text_field(value)
    options = input_html_options.dup
    options[:value] = value

    render_element_id(options)

    options[:class] ||= []
    options[:class] += [" #{input_dom_id} multi-text-field"]
    options[:'aria-labelledby'] = label_id
    @rendered_first_element = true
    @builder.text_field(attribute_name, options)
  end

  def render_element_id(options)
    if @rendered_first_element
      options[:id] = options[:required] = nil
    else
      options[:id] ||= input_dom_id
    end
  end

  def label_id
    input_dom_id + '_label'
  end

  def input_dom_id
    input_html_options[:id] || "#{object_name}_#{attribute_name}"
  end

  def collection
    @collection ||= begin
      Array.wrap(object.send(attribute_name))
    end
  end

  def multiple?
    true
  end
end
