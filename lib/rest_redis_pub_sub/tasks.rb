require 'rest_redis_pub_sub'

namespace :rest_redis_pub_sub do
  task :setup

  desc "Start RestRedisPubSub subscribe worker."
  task :subscribe => [:preload, :setup] do

    RestRedisPubSub.register_signal_handlers

    subscribed_channels = RestRedisPubSub.subscribe_to

    begin
      RestRedisPubSub.redis_instance.subscribe(subscribed_channels) do |on|
        on.subscribe do |channel, subscriptions|
          puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
        end

        on.message do |channel, message|
          puts "##{channel}: #{message}"
          RestRedisPubSub::EventHandler.handle(message)
        end

        on.unsubscribe do |channel, subscriptions|
          puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
        end
      end
    rescue Redis::BaseConnectionError => error
      puts "#{error}, retrying in 1s"
      sleep 1
      retry
    end
  end

  # If Rails preload app files
  task :preload => :setup do
    if defined?(Rails) && Rails.respond_to?(:application)
      Rails.application.eager_load!
    end
  end

end
