require 'json'

module RestRedisPubSub
  class Client

    def initialize(channel=nil)
      @channel = channel
    end

    [:created, :updated, :deleted].each do |method|
      define_method(method) do |resource, identifier, data={}|
        publish(method, resource, identifier, data)
      end
    end

    def channel(resource)
      @channel || RestRedisPubSub.publish_to || "#{RestRedisPubSub.publisher}.#{resource}"
    end

    private

    def publish(event, resource, identifier, data={})
      json_object = {
        publisher: RestRedisPubSub.publisher,
        event: event,
        resource: resource,
        id: identifier,
        data: data
      }.to_json

      RestRedisPubSub.redis_instance.publish(
        channel(resource),
        json_object
      )
    end

  end
end
