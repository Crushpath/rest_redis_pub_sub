require 'json'

module RestRedisPubSub
  class EventHandler

    def self.handle(raw_message)
      message = JSON.parse(raw_message)
      @handler = self.new(message)
      @handler.forward
    rescue JSON::ParserError
      puts 'Invalid message received'
    end

    def initialize(options={})
      @verb = options['verb']
      @generator = options['generator']
      @provider = options['provider']
      @id = options['id']
      @actor= options['actor']
      @object = options['object']
      @target = options['target']
      @activity_type = options['activity_type']
    end

    attr_reader :verb, :generator, :provider, :id, :actor, :object,
                :target, :activity_type

    def forward
      return if class_to_forward.nil?

      if enqueue_forward?
        forward_in_background
      else
        class_to_forward.perform(activity)
      end
    end

    def class_to_forward
      return unless activity_type

      @class_to_forward ||= begin
        class_name_parts = [generator['display_name'], activity_type]
        if namespace = RestRedisPubSub.listeners_namespace
          class_name_parts.unshift(namespace, '::')
        end
        class_name = class_name_parts.map {|part| Helper.camelize(part) }.join
        Helper.constantize_if_defined(class_name)
      end
    end

    def enqueue_forward?
      defined?(Resque)
    end

    def forward_in_background
      Resque.enqueue(class_to_forward, activity)
    end

    def activity
      {
        actor: actor,
        object: object,
        target: target,
        id: id
      }
    end

  end
end
