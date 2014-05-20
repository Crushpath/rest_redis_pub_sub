module RestRedisPubSub
  class Client

    def initialize(channels=nil)
      @channels = channels
    end

    attr_reader :channels

    def publish(event, resource, identifier, data={})
      json_object = {
        publisher: RestRedisPubSub.publisher,
        event: event,
        resource: resource,
        id: identifier,
        data: data
      }.to_json

      RestRedisPubSub.redis_instance.publish(channels, json_object)
    end

  end
end
