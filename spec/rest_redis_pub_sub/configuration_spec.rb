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

    it "allows to set an app generator" do
      RestRedisPubSub.configure do |config|
        config.generator = 'my-app'
      end

      expect(RestRedisPubSub.generator).to eq('my-app')
    end

    it "sets the provider" do
      expect(RestRedisPubSub.provider).to eq("rest_redis_pub_sub #{RestRedisPubSub::VERSION}")
    end

    it "sets the defined verbs" do
      RestRedisPubSub.configure do |config|
        config.verbs = [:test]
      end
      expect(RestRedisPubSub.verbs).to eq([:test])
    end

    it "add the additional_verbs to the verbs list" do
      RestRedisPubSub.configure do |config|
        config.additional_verbs = [:test]
      end
      expect(RestRedisPubSub.additional_verbs).to eq([:test])
      expect(RestRedisPubSub.verbs).to eq(RestRedisPubSub::Configuration::VERBS + [:test])
    end
  end

  describe ".reset!" do
    it "reset the configuration values" do
      Listeners = Class.new
      MyRedis = Class.new
      redis_instance = MyRedis.new
      RestRedisPubSub.configure do |config|
        config.subscribe_to = ["subscribed-channel"]
        config.publish_to = "my-publish-channel"
        config.redis_instance = redis_instance
        config.listeners_namespace = Listeners
        config.verbs = [:create, :update]
        config.additional_verbs = [:awesome]
      end

      RestRedisPubSub.reset!

      expect(RestRedisPubSub.subscribe_to).to be_nil
      expect(RestRedisPubSub.publish_to).to be_nil
      expect(RestRedisPubSub.redis_instance).to be_nil
      expect(RestRedisPubSub.listeners_namespace).to be_nil
      expect(RestRedisPubSub.verbs).to eq(RestRedisPubSub::Configuration::VERBS)
      expect(RestRedisPubSub.additional_verbs).to eq([])
    end
  end

end
