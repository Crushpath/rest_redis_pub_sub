module RestRedisPubSub
  class ResourceSubscriber
    SUBSCRIPTION_KEY = 'subscriptions'

    def initialize(attrs)
       @app = attrs.fetch(:app)
       @resource = attrs.fetch(:resource)
       @id = attrs.fetch(:id)
    end

    attr_reader :app, :resource, :id

    def subscribe
      RestRedisPubSub.redis_instance.sadd(resource_key, RestRedisPubSub.publisher)
    end

    def resource_key
      [SUBSCRIPTION_KEY, app, resource, id].join(':')
    end

  end
end
