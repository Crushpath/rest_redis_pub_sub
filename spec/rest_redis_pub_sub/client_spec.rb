require 'spec_helper'

describe RestRedisPubSub::Client do
  before do
    @redis_instance = double('redis_instance')
    RestRedisPubSub.reset!
    RestRedisPubSub.redis_instance = @redis_instance
    RestRedisPubSub.publisher = 'my-app'
    @expected_data = {
      publisher: RestRedisPubSub.publisher,
      event: nil,
      resource: 'resource',
      id: 'resource-id',
      data: {name: 'resource-name'}
    }
  end

  describe "#created" do
    it "publish a created event for the given resource" do
      @expected_data[:event] = :created
      json_message = @expected_data.to_json
      expect(@redis_instance).to receive(:publish).with('my-app-resource', json_message)

      client = RestRedisPubSub::Client.new('my-app-resource')
      client.created('resource', 'resource-id', {name: 'resource-name'})
    end
  end

  describe "#updated" do
    it "publish an updated event for the given resource" do
      @expected_data[:event] = :updated
      json_message = @expected_data.to_json
      expect(@redis_instance).to receive(:publish).with('my-app-resource', json_message)

      client = RestRedisPubSub::Client.new('my-app-resource')
      client.updated('resource', 'resource-id', {name: 'resource-name'})
    end
  end

  describe "#deleted" do
    it "publish a deleted event for the given resource" do
      @expected_data[:event] = :deleted
      json_message = @expected_data.to_json
      expect(@redis_instance).to receive(:publish).with('my-app-resource', json_message)

      client = RestRedisPubSub::Client.new('my-app-resource')
      client.deleted('resource', 'resource-id', {name: 'resource-name'})
    end
  end

  describe "#channel" do
    it "prioritize custom channel" do
      client = RestRedisPubSub::Client.new('my-custom-channel')
      expect(client.channel('resource')).to eq('my-custom-channel')
    end

    it "should take configured channel is no custom one is provided" do
      RestRedisPubSub.publish_to = 'default-channel'
      client = RestRedisPubSub::Client.new
      expect(client.channel('resource')).to eq('default-channel')
    end

    it "should default to publisher + resource" do
      RestRedisPubSub.publisher = 'my-app'
      client = RestRedisPubSub::Client.new
      expect(client.channel('resource')).to eq('my-app.resource')
    end
  end

end
