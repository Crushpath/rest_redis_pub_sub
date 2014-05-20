module RestRedisPubSub
  module Configuration
    def configure(&block)
      block.call(self)
    end

    attr_accessor :subscribe_to, :publish_to, :generator,
                  :listeners_namespace, :redis_instance
  end

  extend Configuration
end
