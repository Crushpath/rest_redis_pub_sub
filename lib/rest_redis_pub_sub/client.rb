require 'json'

module RestRedisPubSub
  class Client
    EVENT_MAPPER = {
      :request => :requested,
      :create => :created,
      :update => :updated,
      :delete => :deleted
    }

    def initialize(channel=nil)
      @channel = channel
    end

    [:create, :update, :delete, :request].each do |method|
      define_method("publish_#{method}".to_sym) do |resource, identifier, data={}|
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
        event: EVENT_MAPPER[event],
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
