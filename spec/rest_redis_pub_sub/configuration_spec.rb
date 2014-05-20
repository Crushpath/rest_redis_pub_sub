require 'spec_helper'

describe RestRedisPubSub::Configuration do

  describe ".configure" do
    it "allows to set the channels to subscribe to" do
      RestRedisPubSub.configure do |config|
        config.subscribe_to = ['channel-one', 'channel-2']
      end

      expect(RestRedisPubSub.subscribe_to).to eq(['channel-one', 'channel-2'])
    end

    it "allows to set the default channel to publish to" do
      RestRedisPubSub.configure do |config|
        config.publish_to = ['other-app-channel', 'subscribed-channel']
      end

      expect(RestRedisPubSub.publish_to).to eq(['other-app-channel', 'subscribed-channel'])
    end

    it "allows to set a namespace for the listener classes" do
      Listeners = Class.new
      RestRedisPubSub.configure do |config|
        config.listeners_namespace = Listeners
      end

      expect(RestRedisPubSub.listeners_namespace).to eq(Listeners)
    end

    it "allows to set a redis instance" do
      MyRedis = Class.new
      redis_instance = MyRedis.new
      RestRedisPubSub.configure do |config|
        config.redis_instance = redis_instance
      end

      expect(RestRedisPubSub.redis_instance).to eq(redis_instance)
    end
  end

end
