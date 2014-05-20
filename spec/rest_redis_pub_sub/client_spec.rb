require 'spec_helper'

describe RestRedisPubSub::Client do
  before do
    @redis_instance = double('redis_instance')
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

  describe "#channel"

end
