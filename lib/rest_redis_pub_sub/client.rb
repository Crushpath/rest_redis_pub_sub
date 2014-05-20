require 'json'

module RestRedisPubSub
  class Client

    def initialize(channels=nil)
      @channels = channels
    end

    attr_reader :channels

    [:created, :updated, :deleted].each do |method|
      define_method(method) do |resource, identifier, data={}|
        publish(method, resource, identifier, data)
      end
    end

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
