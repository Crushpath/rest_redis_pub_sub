module RestRedisPubSub
  class Publisher
    class NonListeners < StandarError;end

    def self.publish(attrs={})
      if attrs.delete(:enqueue) && background_handler_defined?
        enqueue_publish!(attrs)
        return true
      end
      publisher = self.new(attrs)
      listeners_count = publisher.publish
      if listeners_count <= 0 && background_handler_defined?
        enqueue_if_non_listeners(attrs)
      end
    end

    def self.perform(attrs)
      self.publish(parse_attrs(attrs))
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

    private

    def self.enqueue_if_non_listeners(attrs)
      if attrs.delete('non_listeners')
        raise NonListeners.new("[#{self.to_s}] This event had non listeners.")
      else
        enqueue_publish!(attrs.merge(non_listeners: true))
      end
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
      Resque.enqueue(self, attrs)
    end

    def client
      RestRedisPubSub::Client.new
    end

    def not_implemented_error
      NotImplementedError.new("This method needs to be defined in the child class")
    end

  end
end
