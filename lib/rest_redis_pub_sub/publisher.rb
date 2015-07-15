module RestRedisPubSub
  class Publisher

    def self.publish(attrs={})
      if attrs.delete(:enqueue) && background_handler_defined?
        enqueue_publish!(attrs)
        return true
      end
      publisher = self.new(attrs)
      return true unless publisher.valid?

      listeners_count = publisher.publish
      if publisher.requires_listeners? && listeners_count.to_i <= 0 && background_handler_defined?
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

    def requires_listeners?
      true
    end

    def options
      {
        verb: verb,
        actor: actor,
        object: object,
        target: target,
        source: source,
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

    def valid?
      true
    end

    def persist
      false
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
      (resque_defined? && defined?(Resque::Scheduler)) || sidekiq_defined?
    end

    def self.background_handler_defined?
      resque_defined? || sidekiq_defined?
    end

    def self.resque_defined?
      defined?(Resque)
    end

    def self.sidekiq_defined?
      defined?(Sidekiq)
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
      if resque_defined?
        Resque.enqueue(self, attrs_with_options)
      elsif sidekiq_defined?
        self.perform_async(attrs_with_options)
      end
    end

    def self.enqueue_publish_with_delay(attrs)
      attrs_with_options = attrs.merge(raise_if_no_listeners: raise_if_no_listeners)
      if resque_defined?
        Resque.enqueue_in(120, self, attrs_with_options)
      elsif sidekiq_defined?
        self.perform_in(120, attrs_with_options)
      end
    end

    def client
      persist ? RestRedisPubSub::Client.new : RestRedisPubSub::PersistingClient.new
    end

    def not_implemented_error
      NotImplementedError.new("This method needs to be defined in the child class")
    end

  end
end
