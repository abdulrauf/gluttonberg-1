module Gluttonberg
  module Helpers
    class FormBuilder < ActionView::Helpers::FormBuilder
      include ActionView::Helpers::TagHelper

      def text_field(attribute, options={})
        box_class = add_class!('text', options)
        field(super, attribute, options, box_class)
      end

      def text_area(attribute, options={})
        box_class = add_class!('text', options)
        field(super, attribute, options, box_class)
      end

      def radio_button(attribute, value, label, options = {})
        add_class!('radio', options)
        label_for = "#{object_name}_#{attribute}_#{value}"
        super(attribute, value, options) + label(attribute, :label => label, :class => 'inline', :for => label_for)
      end

      def select(attribute, choices, options={})    
        box_class = add_class!('text', options)
        field(super, attribute, options, box_class)
      end

      private

      def label(method, options = {})
        if options.has_key?(:label)
          super(method, options.delete(:label), options)
        else
          super(method, nil, options)
        end
      end

      def add_class!(klass, options)
        classes = [klass]
        classes << options[:class] if options.has_key?(:class)
        if options.has_key? :size
          parts = options[:size].split('.')
          classes << parts.last
          options[:class] = classes.join(' ')
          parts.first
        else
          options[:class] = classes.join(' ')
          nil
        end
      end

      def field(field, attribute, options, size = nil)
        content = label(attribute, options) + field
        klass = size ? 'field ' + size : 'field'
        content_tag(:p, content, :class => klass)
      end
    end # FormBuilder
  end # Helpers
end # Gluttonberg

