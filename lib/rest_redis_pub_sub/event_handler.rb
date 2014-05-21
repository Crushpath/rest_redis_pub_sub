require 'json'

module RestRedisPubSub
  class EventHandler

    def self.handle(raw_message)
      message = JSON.parse(raw_message)
      @handler = self.new(message)
      @handler.forward
    end

    def initialize(options={})
      @event = options[:event]
      @resource = options[:resource]
      @publisher = options[:publisher]
      @identifier = options[:id]
      @data = options[:data]
    end

    attr_reader :event, :resource, :publisher, :identifier, :data

    def forward
      return if class_to_forward.nil?
      class_to_forward.new(identifier, data).perform
    end

    def class_to_forward
      return unless resource && event

      class_name_parts = [resource, event]
      if namespace = RestRedisPubSub.listeners_namespace
        class_name_parts.unshift(namespace, '::')
      end
      class_name = class_name_parts.map { Helper.camelize(part) }.join
      Helper.constantize_if_defined(class_name)
    end

  end
end
