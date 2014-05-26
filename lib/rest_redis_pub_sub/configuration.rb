module RestRedisPubSub
  module Configuration
    def configure(&block)
      block.call(self)
    end

    attr_accessor :subscribe_to, :publish_to, :generator,
                  :listeners_namespace, :redis_instance

    def reset!
      @subscribe_to = nil
      @publish_to = nil
      @generator = nil
      @listeners_namespace = nil
      @redis_instance = nil
    end
  end

  extend Configuration
end
