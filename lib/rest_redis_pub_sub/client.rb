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

    protected

    def json_object
      unless @json_object
        @json_object = {
            generator: generator,
            provider: provider,
            verb: verb,
            actor: actor,
            object: object,
            target: target,
            source: source,
            id: id,
            activity_type: activity_type,
            published: published
        }

        @json_object.merge!(extensions) if extensions
      end

      @json_object
    end

    def publish(options={})
      RestRedisPubSub.redis_instance.publish(
          channel,
          json_object.to_json
      )
    end

    private

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

    def source
      options.fetch(:source, nil)
    end

    def published
      published_at = options.fetch(:published, Time.now)
      published_at.utc.strftime("%FT%RZ")
    end

    def resource
      object.fetch(:object_type)
    end

    def activity_type
      [resource, verb].join('_')
    end

    def extensions
      value = options.fetch(:extensions, nil)
      value.is_a?(Hash) ? value : nil
    end

  end
end
