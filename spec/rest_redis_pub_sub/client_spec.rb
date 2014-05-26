require 'spec_helper'

describe RestRedisPubSub::Client do
  before do
    @redis_instance = double('redis_instance')
    RestRedisPubSub.reset!
    RestRedisPubSub.redis_instance = @redis_instance
    RestRedisPubSub.generator = 'my-app'
    @expected_data = {
      generator: {display_name: RestRedisPubSub.generator},
      provider: {display_name: "rest_redis_pub_sub #{RestRedisPubSub::VERSION}"},
      verb: nil,
      actor: {display_name: :system},
      object: {object_type: 'resource', display_name: 'resource-name'},
      target: nil,
      id: nil,
      activity_type: nil,
    }
    @input_data = {
      actor: {display_name: :system},
      object: {object_type: 'resource', display_name: 'resource-name'}
    }
  end

  describe "#create" do
    it "publish a create event for the given resource" do
      @expected_data[:verb] = :create
      @expected_data[:activity_type] = :resource_create
      json_message = @expected_data.to_json
      expect(@redis_instance).to receive(:publish).with('my-app-resource', json_message)

      client = RestRedisPubSub::Client.new('my-app-resource')
      client.publish_create(@input_data)
    end
  end

  describe "#channel" do
    it "prioritize custom channel" do
      client = RestRedisPubSub::Client.new('my-custom-channel')
      expect(client.channel).to eq('my-custom-channel')
    end

    it "should take configured channel is no custom one is provided" do
      RestRedisPubSub.publish_to = 'default-channel'
      client = RestRedisPubSub::Client.new
      expect(client.channel).to eq('default-channel')
    end

    it "should default to publisher + resource" do
      RestRedisPubSub.generator = 'my-app'
      client = RestRedisPubSub::Client.new
      client.instance_variable_set(:@options, @input_data)
      expect(client.channel).to eq('my-app.resource')
    end
  end

end
