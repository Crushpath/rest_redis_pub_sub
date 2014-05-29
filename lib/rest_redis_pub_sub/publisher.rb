module RestRedisPubSub
  class Publisher

    def self.publish(attrs={})
      publisher = self.new(attrs)
      publisher.publish
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

    def client
      RestRedisPubSub::Client.new
    end

    def not_implemented_error
      NotImplementedError.new("This method needs to be defined in the child class")
    end

  end
end
