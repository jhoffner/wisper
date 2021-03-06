module Wisper
  class ObjectRegistration < Registration
    attr_reader :with, :prefix, :class_prefix, :allowed_classes, :allow_private

    def initialize(listener, options)
      super(listener, options)
      @with   = options[:with]
      @prefix = stringify_prefix(options[:prefix])
      @class_prefix = options[:class_prefix]
      @allowed_classes = Array(options[:scope]).map(&:to_s).to_set
      fail_on_async if options.has_key?(:async)
    end

    def broadcast(event, publisher, *args)
      method_to_call = map_event_to_method(event, publisher)
      if should_broadcast?(event) && listener.respond_to?(method_to_call) && publisher_in_scope?(publisher)
        if allow_private
          listener.send(method_to_call, *args)
        else
          listener.public_send(method_to_call, *args)
        end
      end
    end

    private

    def publisher_in_scope?(publisher)
      allowed_classes.empty? || publisher.class.ancestors.any? { |ancestor| allowed_classes.include?(ancestor.to_s) }
    end

    def map_event_to_method(event, publisher)
      prefix + publisher_class_prefix(publisher) + (with || event).to_s
    end

    def stringify_prefix(_prefix)
      case _prefix
      when nil
        ''
      when true
        default_prefix + '_'
      else
        _prefix.to_s + '_'
      end
    end

    def publisher_class_prefix(publisher)
      if class_prefix and (name = publisher_class_prefix_name(publisher))
        name = underscore(name) if name.is_a?(String)
        name.to_s + '_'
      else
        ''
      end
    end

    def publisher_class_prefix_name(publisher)
      # publisher class prefix can be overridden by the publisher instance. This can be useful if you
      # have many classes that extend from a base class, and you wish to use that base class as the root prefix.
      if publisher.respond_to?(:publisher_class_prefix)
        publisher.publisher_class_prefix

      # otherwise we just use the class name
      elsif publisher.class.name
        publisher.class.name
      end
    end

    def default_prefix
      'on'
    end

    def fail_on_async
      raise 'The async feature has been moved to the wisper-async gem'
    end
    
    def underscore(str)

      underscored = str.dup
      underscored.gsub!(/::/, '_')
      underscored.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
      underscored.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      underscored.tr!("-", "_")
      underscored.downcase!
      underscored
    end
  end
end
