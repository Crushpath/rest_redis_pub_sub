module RestRedisPubSub
  class Publisher

    def self.publish(attrs={})
      if attrs.delete(:enqueue) && background_handler_defined?
        enqueue_publish!(attrs)
        return true
      end
      publisher = self.new(attrs)
      listeners_count = publisher.publish
      if listeners_count.to_i <= 0 && background_handler_defined?
        handle_if_no_listeners(attrs)
      end
    end

    def self.perform(attrs)
      self.publish(parse_attrs(attrs))
    rescue Resque::TermException
      enqueue_publish!(attrs)
    end

    def publish
      client.send("publish_#{verb}".to_sym, options)
    end

    def options
      {
        verb: verb,
        actor: actor,
        object: object,
        target: target,
        spource: source,
        id: id,
        extensions: extensions
      }
    end

    def verb
      raise not_implemented_error
    end

    def actor
      raise not_implemented_error
    end

    def object
      raise not_implemented_error
    end

    def target
    end

    def id
    end

    def extensions
    end

    def source
    end

    private

    def self.raise_if_no_listeners
      true
    end

    def self.enqueue_if_no_listeners?
      true
    end

    def self.handle_if_no_listeners(attrs)
      if attrs.delete(:raise_if_no_listeners) || attrs.delete('raise_if_no_listeners')
        raise RestRedisPubSub::NoListeners.new("[#{self.to_s}] This event has no listeners.")
      elsif enqueue_if_no_listeners?
        if background_delay_defined?
          enqueue_publish_with_delay(attrs)
        else
          enqueue_publish!(attrs)
        end
      end
    end

    def self.background_delay_defined?
      defined?(Resque::Scheduler)
    end

    def self.background_handler_defined?
      defined?(Resque)
    end

    def self.parse_attrs(attrs)
      if defined?(HashWithIndifferentAccess)
        HashWithIndifferentAccess.new(attrs)
      else
        attrs
      end
    end

    def self.enqueue_publish!(attrs)
      attrs_with_options = attrs.merge(raise_if_no_listeners: raise_if_no_listeners)
      Resque.enqueue(self, attrs_with_options)
    end

    def self.enqueue_publish_with_delay(attrs)
      attrs_with_options = attrs.merge(raise_if_no_listeners: raise_if_no_listeners)
      Resque.enqueue_in(120, self, attrs_with_options)
    end

    def client
      RestRedisPubSub::Client.new
    end

    def not_implemented_error
      NotImplementedError.new("This method needs to be defined in the child class")
    end

  end
end
