require 'json'

module RestRedisPubSub
  class Client

    def self.define_publish_methods
      RestRedisPubSub.verbs.each do |verb|
        define_method("publish_#{verb}".to_sym) do |options={}|
          @options = options.merge(verb: verb)
          publish
        end
      end
    end

    def initialize(channel=nil)
      @channel = channel
    end
    attr_reader :options

    def channel
      @channel || RestRedisPubSub.publish_to || "#{RestRedisPubSub.generator}.#{resource}"
    end

    private

    def publish(options={})
      json_object = {
        generator: generator,
        provider: provider,
        verb: verb,
        actor: actor,
        object: object,
        target: target,
        id: id,
        activity_type: activity_type
      }.to_json

      RestRedisPubSub.redis_instance.publish(
        channel,
        json_object
      )
    end

    def generator
      { display_name: RestRedisPubSub.generator }
    end

    def provider
      { display_name: RestRedisPubSub.provider }
    end

    def actor
      options.fetch(:actor)
    end

    def object
      options.fetch(:object)
    end

    def verb
      options.fetch(:verb, :post)
    end

    def id
      options.fetch(:id, nil)
    end

    def target
      options.fetch(:target, nil)
    end

    def published
      options.fetch(:published, Time.now)
    end

    def resource
      object.fetch(:object_type)
    end

    def activity_type
      [resource, verb].join('_')
    end

  end
end
