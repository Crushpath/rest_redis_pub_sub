require 'json'

module RestRedisPubSub
  class EventHandler

    def self.handle(raw_message)
      message = JSON.parse(raw_message)
      @handler = self.new(message)
      @handler.forward
    end

    def initialize(options={})
      @event = options['event']
      @resource = options['resource']
      @publisher = options['publisher']
      @identifier = options['id']
      @data = options['data']
    end

    attr_reader :event, :resource, :publisher, :identifier, :data

    def forward
      return if class_to_forward.nil?

      if enqueue_forward?
        forward_in_background
      else
        class_to_forward.perform(identifier, data)
      end
    end

    def class_to_forward
      return unless resource && event

      @class_to_forward ||= begin
        class_name_parts = [resource, event]
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
      Resque.enqueue(class_to_forward, identifier, data)
    end

  end
end
